/**
 * HealVision — Cloud Functions (Firebase Functions v2, Node 20)
 *
 * Provides the server-side pieces of the recovery companion so no secret ever
 * ships inside the Flutter APK:
 *   - claudeChat        (callable) : recovery-focused chatbot backed by Claude
 *   - dailyMotivation   (callable) : short streak-aware encouragement from Claude
 *   - sendCheckinReminder (HTTP)   : inbound webhook that fans out an FCM push
 *
 * Secrets (set once with `firebase functions:secrets:set <NAME>`):
 *   - ANTHROPIC_API_KEY : your Anthropic API key
 *   - WEBHOOK_SECRET    : shared secret the external scheduler must send
 */

const { onCall, onRequest, HttpsError } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");
const Anthropic = require("@anthropic-ai/sdk");

admin.initializeApp();
const db = admin.firestore();

const ANTHROPIC_API_KEY = defineSecret("ANTHROPIC_API_KEY");
const WEBHOOK_SECRET = defineSecret("WEBHOOK_SECRET");

// Latest, most capable Claude model. Swap to "claude-sonnet-5" (cheaper/faster)
// or "claude-haiku-4-5" if you want to trade some quality for cost/latency.
const CLAUDE_MODEL = "claude-opus-4-8";

// Recovery-companion persona. Kept as a constant so it is easy to iterate on.
const SYSTEM_PROMPT = `You are HealVision, a warm, non-judgmental recovery companion for someone working to stay free from substance use. You are speaking with a person who has recently stopped using and wants day-to-day support to stay on track.

Your role:
- Be supportive, encouraging, and calm. Celebrate progress, however small.
- Help the user cope with cravings, stress, low mood, and difficult moments in the present, using practical grounding, distraction, and reframing techniques.
- Reinforce their reasons to stay clean and the streak they have built.
- Encourage healthy routines: sleep, food, movement, connection, and logging their mood.

Boundaries (important):
- You are NOT a doctor or therapist and do not give medical, diagnostic, or medication advice. Encourage professional help for those.
- If the user expresses thoughts of self-harm, suicide, overdose, or is in crisis, respond with care and urge them to contact local emergency services or a crisis line immediately, and to reach a trusted person. Do not attempt to handle a crisis alone.
- Never encourage, minimize, or give instructions related to substance use.

Style:
- Keep replies short and conversational (2-5 sentences), like a caring friend texting back. Avoid lists unless the user asks for steps.
- Respond directly with your final message only. Do not include analysis of your own reasoning.`;

/** Coerce an incoming client history array into Anthropic message params. */
function toAnthropicMessages(history, latestUserMessage) {
  const messages = [];
  if (Array.isArray(history)) {
    for (const item of history) {
      if (!item || typeof item.text !== "string" || item.text.trim() === "") {
        continue;
      }
      const role = item.role === "assistant" ? "assistant" : "user";
      messages.push({ role, content: item.text });
    }
  }
  messages.push({ role: "user", content: latestUserMessage });
  return messages;
}

/** Extract the plain-text reply from a Claude response. */
function textFromResponse(response) {
  return (response.content || [])
    .filter((block) => block.type === "text")
    .map((block) => block.text)
    .join("")
    .trim();
}

/**
 * claudeChat — the recovery chatbot.
 * data: { message: string, history?: [{ role: 'user'|'assistant', text: string }] }
 * returns: { reply: string }
 */
exports.claudeChat = onCall(
  { secrets: [ANTHROPIC_API_KEY], region: "us-central1" },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Sign in to use the chat.");
    }
    const message = (request.data && request.data.message) || "";
    if (typeof message !== "string" || message.trim() === "") {
      throw new HttpsError("invalid-argument", "message must not be empty.");
    }

    const client = new Anthropic({ apiKey: ANTHROPIC_API_KEY.value() });
    try {
      const response = await client.messages.create({
        model: CLAUDE_MODEL,
        max_tokens: 1024,
        system: SYSTEM_PROMPT,
        messages: toAnthropicMessages(request.data.history, message.trim()),
      });
      return { reply: textFromResponse(response) };
    } catch (err) {
      logger.error("claudeChat failed", err);
      throw new HttpsError("internal", "The assistant is unavailable right now.");
    }
  }
);

/**
 * dailyMotivation — a short streak-aware encouragement.
 * data: { streakDays?: number, reasons?: string }
 * returns: { message: string }
 */
exports.dailyMotivation = onCall(
  { secrets: [ANTHROPIC_API_KEY], region: "us-central1" },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Sign in first.");
    }
    const streakDays = Number(request.data && request.data.streakDays) || 0;
    const reasons = (request.data && request.data.reasons) || "";

    const prompt = `Write one short, uplifting message (max 2 sentences) for someone who is ${streakDays} day(s) into staying free from substance use.${reasons ? ` Their personal reasons to quit: ${reasons}.` : ""} Be warm and specific to the streak. No emojis unless it fits naturally. Return only the message.`;

    const client = new Anthropic({ apiKey: ANTHROPIC_API_KEY.value() });
    try {
      const response = await client.messages.create({
        model: CLAUDE_MODEL,
        max_tokens: 200,
        system: SYSTEM_PROMPT,
        messages: [{ role: "user", content: prompt }],
      });
      return { message: textFromResponse(response) };
    } catch (err) {
      logger.error("dailyMotivation failed", err);
      throw new HttpsError("internal", "Could not generate a message right now.");
    }
  }
);

/**
 * sendCheckinReminder — inbound webhook for an external scheduler
 * (cron-job.org, Zapier, GitHub Actions, etc.) to trigger a check-in push.
 *
 * POST JSON:
 *   { "secret": "<WEBHOOK_SECRET>",   // or header "x-webhook-secret"
 *     "uid": "<optional single user>",
 *     "title": "Time to check in",
 *     "body": "How are you feeling today?" }
 *
 * Delivers an FCM push to the stored device tokens.
 */
exports.sendCheckinReminder = onRequest(
  { secrets: [WEBHOOK_SECRET], region: "us-central1" },
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).json({ error: "Use POST." });
      return;
    }
    const provided =
      req.get("x-webhook-secret") || (req.body && req.body.secret) || "";
    if (provided !== WEBHOOK_SECRET.value()) {
      res.status(401).json({ error: "Invalid webhook secret." });
      return;
    }

    const title = (req.body && req.body.title) || "HealVision check-in";
    const body =
      (req.body && req.body.body) ||
      "How are you feeling today? Take a moment to log your mood.";
    const uid = req.body && req.body.uid;

    try {
      // Collect target device tokens.
      let tokens = [];
      if (uid) {
        const doc = await db.collection("Users").doc(uid).get();
        tokens = (doc.exists && doc.data().fcmTokens) || [];
      } else {
        const snap = await db
          .collection("Users")
          .where("fcmTokens", "!=", null)
          .get();
        snap.forEach((d) => {
          const t = d.data().fcmTokens;
          if (Array.isArray(t)) tokens.push(...t);
        });
      }
      tokens = [...new Set(tokens)].filter(Boolean);

      if (tokens.length === 0) {
        res.status(200).json({ sent: 0, note: "No device tokens registered." });
        return;
      }

      const response = await admin.messaging().sendEachForMulticast({
        tokens,
        notification: { title, body },
        data: { type: "checkin" },
      });

      // Prune tokens FCM reports as no longer valid.
      const stale = [];
      response.responses.forEach((r, i) => {
        if (
          !r.success &&
          r.error &&
          ["messaging/invalid-registration-token",
           "messaging/registration-token-not-registered"].includes(r.error.code)
        ) {
          stale.push(tokens[i]);
        }
      });
      if (stale.length) {
        const batch = db.batch();
        const users = await db
          .collection("Users")
          .where("fcmTokens", "array-contains-any", stale.slice(0, 10))
          .get();
        users.forEach((d) => {
          batch.update(d.ref, {
            fcmTokens: admin.firestore.FieldValue.arrayRemove(...stale),
          });
        });
        await batch.commit();
      }

      res.status(200).json({ sent: response.successCount, failed: response.failureCount });
    } catch (err) {
      logger.error("sendCheckinReminder failed", err);
      res.status(500).json({ error: "Failed to send reminder." });
    }
  }
);

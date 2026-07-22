# Companion backend contract

The app **never calls Anthropic directly.** Every message goes to *your* proxy,
which holds the API key, injects the system prompt, rate-limits, runs the crisis
check, and returns only the assistant text plus a crisis flag.

You told me you already have the backend + token — so this file is the spec your
endpoint needs to match for the in-app chat to work. There's an optional
reference Worker at the bottom if you want to diff against something that already
implements this exact contract.

---

## 1. The endpoint the app calls

```
POST  <baseUrl>/chat
```

The app appends `/chat` if your base URL doesn't already end in it — so both
`https://your-worker.workers.dev` and `https://…/chat` work.

### Request

Headers:

| Header          | Value                       |
| --------------- | --------------------------- |
| `Authorization` | `Bearer <token>`            |
| `Content-Type`  | `application/json`          |
| `Accept`        | `text/event-stream`         |

Body:

```jsonc
{
  "userId": "8Zx…",              // stable per-install id, for rate limiting only
  "messages": [                  // full recent history, oldest → newest
    { "role": "user",      "content": "hey" },
    { "role": "assistant", "content": "Hi — good to see you. What's going on?" },
    { "role": "user",      "content": "rough night, cravings are loud" }
  ]
}
```

- **No system message is ever sent by the client.** Inject it server-side
  (section 3) so it can't be tampered with.
- The app caps history to the last ~24 turns.

### Response — pick either shape; the app handles both

**A) Streaming (preferred)** — `Content-Type: text/event-stream`:

```
event: delta
data: {"text": "I hear you — "}

event: delta
data: {"text": "loud cravings are exhausting."}

event: done
data: {"crisis": false}
```

- Emit `event: error` + `data: {"message": "..."}` to show a gentle error.
- A raw Anthropic passthrough also works: the app understands
  `content_block_delta` / `message_stop` events. If you passthrough raw, send the
  crisis flag as its own final `data: {"crisis": true}` line before closing.

**B) Single JSON** — `Content-Type: application/json`:

```json
{ "text": "I hear you — loud cravings are exhausting.", "crisis": false }
```

The app reveals it progressively so it still feels like typing.

### Status codes

| Code      | App behavior                                            |
| --------- | ------------------------------------------------------- |
| `200`     | Read body per content-type above                        |
| `401/403` | "Not authorized — check the access token in settings"   |
| `429`     | "Let's take a short breather and try again in a minute" |
| `>=400`   | Generic gentle retry message                            |

---

## 2. What the backend MUST do

- [ ] Hold `ANTHROPIC_API_KEY` as a server-side secret. Never return it.
- [ ] Inject the system prompt in section 3 on every request.
- [ ] Require the bearer token (basic auth on the endpoint).
- [ ] Rate-limit per `userId` (e.g. ~20 msgs / 5 min).
- [ ] Run the crisis check (section 4) on **the user's latest message** and on
      **the model's output**; return `crisis: true` if either trips.
- [ ] Use a current model — default `claude-sonnet-4-6` (good quality/cost), or
      `claude-haiku-4-5` for lower cost/latency. Confirm the latest string at
      <https://docs.claude.com/en/docs/about-claude/models>.
- [ ] Return only assistant text + the crisis flag.
- [ ] **Never log message content in plaintext.** Log counts/latency/flags only.

---

## 3. System prompt (inject verbatim, server-side)

```text
You are a warm, supportive recovery companion inside an app for someone working to stay free from drug use. You are NOT a therapist, doctor, or crisis service, and you say so plainly if asked.

How you talk:
- Warm, non-judgmental, and hopeful. Use the spirit of motivational interviewing: ask open questions, reflect back what you hear, affirm effort, and support the person's own reasons for change. Never lecture or shame.
- Keep responses fairly short and human. Listen more than you advise.
- Meet slips and relapses with compassion, never judgment. Frame them as part of many people's recovery and something to learn from.
- Celebrate wins, however small.

Hard boundaries:
- Do NOT give medical advice, dosing, tapering, or withdrawal-management instructions. If asked, gently explain that this needs a medical professional and encourage them to reach one.
- Do NOT diagnose.
- Do NOT provide any information that could facilitate obtaining or using drugs.
- Always encourage professional treatment, peer support (meetings, groups), and connection with trusted people as the real backbone of recovery — you are a companion alongside those, not a replacement.

Crisis handling (highest priority):
- If the person expresses thoughts of suicide, self-harm, hopelessness of that kind, overdose, or being in danger, respond with calm compassion, take it seriously, and immediately share crisis resources: in the US, call or text 988 (Suicide & Crisis Lifeline), or 911 for an emergency; SAMHSA's helpline 1-800-662-4357 for substance-use support. Gently, firmly encourage reaching a real person right now. Do not try to be their only support in that moment.

Privacy: treat everything shared as private and sensitive.
```

---

## 4. Crisis-term check (both sides run it)

Enforce crisis handling in code so it doesn't depend on the model's wording. The
app runs the same list on-device as a fallback; keep them aligned. Normalize to
lowercase and test as substrings:

```js
const CRISIS_PHRASES = [
  "kill myself", "killing myself", "end my life", "ending my life", "end it all",
  "take my life", "want to die", "wanna die", "wish i was dead", "wish i were dead",
  "better off dead", "suicidal", "suicide", "self harm", "self-harm",
  "hurt myself", "harm myself", "cut myself", "no reason to live",
  "don't want to be here anymore", "dont want to be here anymore",
  "can't go on", "cant go on", "overdose", "overdosed", "od on",
  "take the whole bottle", "want it to stop",
];

const looksLikeCrisis = (text) => {
  const t = (text || "").toLowerCase();
  return CRISIS_PHRASES.some((p) => t.includes(p));
};
```

Set `crisis: true` when the latest user message **or** the assistant reply trips
it. The app then surfaces the crisis resources UI regardless of the chat text.

---

## 5. Optional reference — Cloudflare Worker

Implements this contract exactly (streaming SSE + crisis flag + rate limit +
bearer auth), using the official Anthropic SDK. Diff your existing code against
it if you want to be sure the shapes line up.

```ts
// src/index.ts  —  npm i @anthropic-ai/sdk   |   deploy: wrangler deploy
import Anthropic from "@anthropic-ai/sdk";

const SYSTEM_PROMPT = `PASTE THE SECTION 3 PROMPT HERE, VERBATIM`;

const CRISIS_PHRASES = [ /* the section 4 list */ ];
const looksLikeCrisis = (t: string) =>
  CRISIS_PHRASES.some((p) => (t || "").toLowerCase().includes(p));

export interface Env {
  ANTHROPIC_API_KEY: string;   // wrangler secret put ANTHROPIC_API_KEY
  APP_TOKEN: string;           // wrangler secret put APP_TOKEN  (the app's bearer)
  RATE: KVNamespace;           // [[kv_namespaces]] binding = "RATE"
  MODEL?: string;              // optional var, defaults below
}

export default {
  async fetch(req: Request, env: Env): Promise<Response> {
    if (req.method !== "POST") return new Response("Not found", { status: 404 });

    // --- basic auth ---
    const auth = req.headers.get("authorization") || "";
    if (auth !== `Bearer ${env.APP_TOKEN}`) {
      return new Response("Unauthorized", { status: 401 });
    }

    const { userId, messages } = await req.json<any>();
    if (!Array.isArray(messages)) return new Response("Bad request", { status: 400 });

    // --- per-user rate limit: 20 / 5 min ---
    const key = `rl:${userId ?? "anon"}`;
    const count = parseInt((await env.RATE.get(key)) ?? "0", 10);
    if (count >= 20) return new Response("Slow down", { status: 429 });
    await env.RATE.put(key, String(count + 1), { expirationTtl: 300 });

    const lastUser = [...messages].reverse().find((m) => m.role === "user")?.content ?? "";
    let crisis = looksLikeCrisis(lastUser);

    const client = new Anthropic({ apiKey: env.ANTHROPIC_API_KEY });
    const model = env.MODEL ?? "claude-sonnet-4-6";

    const encoder = new TextEncoder();
    const stream = new ReadableStream({
      async start(controller) {
        const send = (event: string, data: unknown) =>
          controller.enqueue(encoder.encode(`event: ${event}\ndata: ${JSON.stringify(data)}\n\n`));
        try {
          let full = "";
          const run = client.messages.stream({
            model,
            max_tokens: 1024,
            system: SYSTEM_PROMPT,
            messages: messages.map((m: any) => ({ role: m.role, content: m.content })),
          });
          run.on("text", (t) => { full += t; send("delta", { text: t }); });
          await run.finalMessage();
          if (looksLikeCrisis(full)) crisis = true;
          send("done", { crisis });
        } catch (e) {
          send("error", { message: "The server had trouble responding." });
        } finally {
          controller.close();
        }
      },
    });

    return new Response(stream, {
      headers: {
        "content-type": "text/event-stream; charset=utf-8",
        "cache-control": "no-cache",
        "connection": "keep-alive",
      },
    });
  },
};
```

Deploy notes: `wrangler secret put ANTHROPIC_API_KEY`, `wrangler secret put
APP_TOKEN`, add a KV namespace bound as `RATE`, then `wrangler deploy`. Put the
resulting URL + the `APP_TOKEN` value into the app under **Me → AI Companion**.

> Do not paste the raw API key into the app — only the `APP_TOKEN`, which is the
> bearer for *your* endpoint, ever reaches the device.

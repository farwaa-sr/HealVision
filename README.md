# "HEALVISION: ENHANCING SUD RECOVERY THROUGH MOBILE TECHNOLOGY AND ASPECT-BASED EMOTION ANALYSIS"
by
Mujtaba Abbas & Syeda Farwa Rizvi
Supervisor: Tayyaba Arshad

## Objective:
- Develop a mobile application to address SUD through early detection, monitoring, and emotional support.
- Utilize AI to predict user emotions based on textual data, enabling personalized interventions.
- Improve accessibility to SUD care and reduce associated negative impacts.

## Methodology:
- Data Collection: Created a balanced dataset of 6003 dialogues labeled across 6 emotion classes (Emotions-6000).
- Model Development: Implemented various AI models including BERT-ANN, FNN, Naive Bayes, and Random Forest.
- Model Evaluation: BERT-ANN achieved 99.9% training accuracy and 79.33% testing accuracy on Emotions-6000. Demonstrated superior performance with custom input data compared to FNN on a balanced dataset.
- Application Development: Built a Flutter-based mobile application incorporating emotion detection, addiction assessment, appointment scheduling, health tracking, and a chatbot.

## Key Findings:
- AI-powered emotion classification from textual data is feasible and valuable for SUD management.
- BERT-ANN model effectively predicts user emotions, informing personalized interventions.
- The mobile application has the potential to improve accessibility and outcomes for individuals with SUD.

## Future Directions:
- Expand dataset to enhance model robustness and accuracy.
- Explore additional AI techniques for deeper emotion analysis.
- Integrate wearable devices for comprehensive health monitoring.
- Conduct larger-scale user studies to evaluate clinical efficacy.

## Impact:
- Addresses critical public health issue of SUD.
- Leverages AI for innovative and effective care delivery.
- Improves patient outcomes and quality of life.
- Contributes to Sustainable Development Goals (SDG 3, 10, 16).

### View the Presentation with Demo on: https://www.canva.com/design/DAGKQlTnP-Q/SeCBZNRKGDp4FxnxJlHmyw/edit?utm_content=DAGKQlTnP-Q&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton 

## Personal Recovery Companion (updated build)

HealVision has been refocused into a **single-user recovery companion** — no therapist
role, no appointment booking. The dashboard tracks a sobriety streak, mood/craving
check-ins, an assessment-score trend, and daily AI encouragement. The chatbot now runs
on the **Anthropic Claude API** via a Firebase Cloud Function (the API key stays
server-side), and inbound webhooks trigger check-in push notifications (FCM).

### Setup / Guide to View
1. **Cloud Functions** (Directory: `healvision/functions`) — requires the Firebase Blaze plan.
   - `cd healvision/functions && npm install`
   - Set the server secrets (never committed):
     - `firebase functions:secrets:set ANTHROPIC_API_KEY`  (your Anthropic API key)
     - `firebase functions:secrets:set WEBHOOK_SECRET`      (any random string)
   - Deploy: `firebase deploy --only functions`
   - Functions: `claudeChat` + `dailyMotivation` (callable) and `sendCheckinReminder` (HTTP webhook).
2. **Check-in reminders (optional)** — point an external scheduler (cron-job.org, Zapier,
   GitHub Actions, …) at the deployed `sendCheckinReminder` URL with a POST body
   `{ "secret": "<WEBHOOK_SECRET>", "title": "...", "body": "..." }`. It fans out an FCM
   push to registered devices.
3. **Flutter app** (Directory: `healvision`, Android) — `flutter pub get` then `flutter run`.
   The app calls the callable functions directly; no ngrok URL or client-side API key needed.

PS: The legacy BERT emotion-detection API (`healvision API/myapi.py`) is no longer used by
the app. The model training notebook is linked below for reference.

## Dataset: https://www.kaggle.com/datasets/farwarizvi/emotions-6000/data
## Notebook: https://www.kaggle.com/code/farwarizvi/bert-ann-on-emotions-6000-v2

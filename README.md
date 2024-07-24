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

## Guide to View:
1. Deploy the model by running the myapi.py file in CLI Virtual Environment, ensure the Authentication token is set according to your token on Ngrok (Directory: healvision API) 
2. Once the API is running, you will get a Ngrok Public URL. Copy this URL to 'baseURL' variable (in chat_bot_controller.dart)
3. Ensure the Gemini API is also funcitoning, else create a new API key from AI studio and replace.
4. Run the Flutter app, made for Android. (Directory: healvision)

PS: The model trained size is above limit, therefore it is could not be uploaded

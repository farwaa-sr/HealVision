from pyngrok import ngrok

# Replace "YOUR_NGROK_AUTH_TOKEN" with your actual ngrok auth token
ngrok.set_auth_token("2hrtTNIVvWwK928IQM7TtpBnRHr_2TLEsL4QAHJye24apqCYb")
import nest_asyncio
import uvicorn
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import torch
import joblib
from transformers import BertTokenizer, BertModel
from pyngrok import ngrok
import nest_asyncio
import uvicorn
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import torch
import torch.nn as nn  # Ensure you import torch.nn
import joblib
from transformers import BertTokenizer
app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Load the necessary tools
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# Define the ANN model with BERT embeddings
class Text_ANN(nn.Module):
    def __init__(self, bert_model, input_dim, num_classes):
        super(Text_ANN, self).__init__()
        self.bert = bert_model
        self.fc1 = nn.Linear(input_dim, 4000)
        self.fc2 = nn.Linear(4000, 1000)
        self.fc3 = nn.Linear(1000, num_classes)
        self.fc4 = nn.Linear(300, num_classes)
        self.bn1 = nn.BatchNorm1d(4000)
        self.bn2 = nn.BatchNorm1d(1000)
        self.bn3 = nn.BatchNorm1d(300)
        self.dp = nn.Dropout(p=0.1)

    def forward(self, input_ids, attention_mask, token_type_ids=None):
        with torch.no_grad():
            outputs = self.bert(input_ids=input_ids, attention_mask=attention_mask, token_type_ids=token_type_ids)
            embeddings = outputs.last_hidden_state.mean(dim=1)  # Mean pooling

        x = self.fc1(embeddings)
        x = self.bn1(x)
        x = torch.relu(x)
        x = self.dp(x)
        x = self.fc2(x)
        x = self.bn2(x)
        x = torch.relu(x)
        x = self.dp(x)
        x = self.fc3(x)
        # x = self.bn3(x)
        # x = torch.relu(x)
        # x = self.dp(x)
        # x = self.fc4(x)
        return x
bert_model = BertModel.from_pretrained('bert-base-uncased')
device = torch.device('cpu')
bert_model.to(device)
input_dim = bert_model.config.hidden_size  # 768 for BERT base
num_classes = 6  # Number of classes
model = Text_ANN(bert_model, input_dim, num_classes).to(device)
model.load_state_dict(torch.load("text_ann_model1.pth", map_location=torch.device('cpu')))
model.eval()

label_encoder = joblib.load("label_encoder1.pkl")
tokenizer = BertTokenizer.from_pretrained('bert-base-uncased')

def preprocess(text: str):
    return tokenizer(text, return_tensors="pt", padding=True, truncation=True, max_length=512).to(device)

class TextInput(BaseModel):
    text: str

@app.post("/predict-emotion")
async def predict_emotion(input: TextInput):
    if input.text == "":
        raise HTTPException(status_code=400, detail="Text input must not be empty")

    inputs = preprocess(input.text)
    with torch.no_grad():
        outputs = model(**inputs)
        prediction = torch.argmax(outputs, dim=1).cpu().numpy()

    predicted_emotion = label_encoder.inverse_transform(prediction)[0]

    return {"emotion": predicted_emotion}

# Apply the nest_asyncio patch
nest_asyncio.apply()

# Create a public URL using ngrok
public_url = ngrok.connect(8000)
print(f"Public URL: {public_url}")

# Run the app
uvicorn.run(app, host="0.0.0.0", port=8000)

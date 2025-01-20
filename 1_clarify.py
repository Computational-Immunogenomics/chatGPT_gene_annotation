import pandas as pd
import pickle

# Open the pickle file in binary read mode
with open('go_annotation_raw.pkl', 'rb') as file:
    data = pickle.load(file)

def clarify(response):
    base = response.choices[0].message.content.split("\n\n")[1].split("\n")[2:]
    return [i[2:-2].strip() for i in base]

clarifications = [clarify(i) for i in data]
straight_answers = [i.split("|") for j in clarifications for i in j]
clean_answers = [[i.strip() for i in j] for j in straight_answers]

### Send output #### 
pd.DataFrame(clean_answers).to_csv("go_annotation.csv", index = False)

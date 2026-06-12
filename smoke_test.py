import requests
base='http://127.0.0.1:8000'
print('ROOT', requests.get(base+'/').status_code, requests.get(base+'/').json())
reg = requests.post(base+'/register', json={'username':'testuser2','email':'testuser2@example.com','password':'TestPassword123'})
print('REGISTER', reg.status_code, reg.text)
login = requests.post(base+'/login', json={'email':'testuser2@example.com','password':'TestPassword123'})
print('LOGIN', login.status_code, login.text)
if login.status_code == 200:
    token = login.json()['access_token']
    headers = {'Authorization': f'Bearer {token}'}
    profile = requests.get(base+'/profile', headers=headers)
    print('PROFILE', profile.status_code, profile.text)
    chat = requests.post(base+'/chat', json={'message':'Hello','session_id':'testsession'}, headers=headers)
    print('CHAT', chat.status_code, chat.text)
else:
    print('SKIPPED PROFILE/CHAT DUE TO LOGIN')

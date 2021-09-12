Generate a user with a password
```bash
htdigest -c pwd realm username
```

Convert the digest to base64 to store it within a secret
```bash
echo -n username:realm:hashedpwd | base64
```

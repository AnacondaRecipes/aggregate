from cryptacular.bcrypt import BCRYPTPasswordManager

manager = BCRYPTPasswordManager()
hashed = manager.encode('password')
assert manager.check(hashed, 'password')

Use this command to generate credentials
```bash
echo $(htpasswd -nB chris) | sed -e s/\\$/\\$\\$/g
```
## Configuration Checklist

- [x] Make sure DOCKER_GID is correct. <br/>
      Use Command:<br/>
      ```bash
         getent group docker
      ```
      <br/>
        or 
      <br/>
      ```bash
         grep docker /etc/group
      ```
- [x] Ensure ./jupyter-home (the folder that will contain all of your data) has the right permissions.
      <br/>
      Use:
      <br/>
      ```bash
      sudo chown -R 1000:100 ./jupyter-home
      ```
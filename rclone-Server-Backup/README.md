## Backup your entire server to G-Drive!
### Prerequisites:
    - Created an rclone.conf file with:
    ```bash
    rclone config
    ```

### Assumptions:
    - This setup assumes that all of the data that you want to backup (config files and bind mounts etc) are in ~/server. You can change this by editing the volume bind mount in the docker-compose that points to /mnt/server.


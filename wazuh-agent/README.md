# Vulcan Agent (Wazuh Agent)

Deploy the agent using Docker. The agent will register as **vulcan-agent** in the Vulcan Defense dashboard.

## Setup

1. Edit `docker-compose.yml` and set `WAZUH_MANAGER_SERVER` to your manager IP/hostname:
   ```yaml
   environment:
     - WAZUH_MANAGER_SERVER=<YOUR_MANAGER_IP>
   ```

2. Start the agent:
   ```bash
   docker compose up -d
   ```

For single-node deployment, use the manager hostname (e.g. `wazuh.manager` if on same Docker network).

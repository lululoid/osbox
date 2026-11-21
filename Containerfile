FROM node:slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl \
    && rm -rf /var/lib/apt/lists/*
RUN npm install -g @kilocode/cli

WORKDIR /workspace
CMD ["kilo"]

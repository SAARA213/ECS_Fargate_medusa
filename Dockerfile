FROM node:18-alpine

# Set working directory
WORKDIR /usr/src/app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install Medusa CLI globally and project dependencies
RUN npm install -g @medusajs/medusa-cli \
    && npm install

# Copy all project files
COPY . .

# Expose the port that Medusa will run on
EXPOSE 9000

# Command to run migrations and start the Medusa server
CMD ["sh", "-c", "medusa migrations run && medusa start"]

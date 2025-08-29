# Use an official Node.js LTS image as the base
FROM node:18-alpine

# Set the working directory in the container
WORKDIR /app

# Copy package.json and lockfile first (for faster builds)
COPY package.json package-lock.json* ./

# Install dependencies
RUN npm install --production

# Copy the rest of the application code
COPY . .

# Use environment variable for flexibility
ENV PORT=3000
EXPOSE $PORT

# Set the container entrypoint
CMD ["npm", "run", "start"]

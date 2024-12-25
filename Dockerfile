FROM node:latest

# Hexo default
EXPOSE 4000

COPY . /app
WORKDIR /app
RUN npm install

WORKDIR /app/blog
CMD npx hexo server

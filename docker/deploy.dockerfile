FROM myblog:dev

WORKDIR /app/blog
RUN npx hexo generate

CMD npx hexo server -s

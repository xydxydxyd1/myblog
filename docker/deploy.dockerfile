FROM httpd

# build dependencies
RUN apt update
RUN apt install -y nodejs
RUN apt install -y npm

# build static site
COPY . /app
WORKDIR /app/blog
RUN npm install
RUN npx hexo generate

RUN rm -rf /usr/local/apache2/htdocs
RUN mv /app/blog/public /usr/local/apache2/htdocs
#CMD bash

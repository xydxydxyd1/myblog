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

# set up https
WORKDIR /usr/local/apache2
COPY certs/* conf
RUN sed -i \
		-e 's/^#\(Include .*httpd-ssl.conf\)/\1/' \
		-e 's/^#\(LoadModule .*mod_ssl.so\)/\1/' \
		-e 's/^#\(LoadModule .*mod_socache_shmcb.so\)/\1/' \
		conf/httpd.conf

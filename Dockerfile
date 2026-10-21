FROM nginx:1.27-alpine
ARG BUILD=0
RUN echo "<h1>Hello from Jenkins build ${BUILD}</h1>" > /usr/share/nginx/html/index.html

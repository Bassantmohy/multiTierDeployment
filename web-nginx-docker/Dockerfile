FROM nginx:1.28


COPY nginx.conf /etc/nginx/nginx.conf

COPY fullchain.pem /etc/nginx/ssl/fullchain.pem

COPY privkey.pem /etc/nginx/ssl/privkey.pem

CMD ["nginx", "-g", "daemon off;"]
Portable application container with a compressed** size of around 32M.

Typical usage: `docker run -d -p 80:80 --name wp-lemp-lite realies/wp-lemp-lite`

Default environment variables that can be overwritten:

`DB_NAME=wordpress`
`DB_USER=wordpress`
`DB_PASS=secret`

Web-server root and database data located within `/data/www` and `/data/mariadb` respectively.

---
** Compressed using `xz -9e`

frontend:
	@bash components/frontend.sh

mongodb:
	@bash components/mongodb.sh

catalogue:
	@bash components/catalogue.sh

redis:
	@bash components/redis.sh

user:
	@bash components/user.sh

cart:
	@bash components/cart.sh

mysql:
	@bash components/mysql.sh

shipping:
	@bash components/shipping.sh

rabbitmq:
	@bash components/rabbitmq.sh

payment:
	@bash components/payment.sh

dispatch:
	@bash components/dispatch.sh
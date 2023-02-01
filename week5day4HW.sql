--1
CREATE OR REPLACE PROCEDURE sevenDayFee(LateFee NUMERIC)
LANGUAGE plpgsql
AS $$
BEGIN
	UPDATE payment
	SET amount = amount + LateFee
	WHERE customer_id IN(
		SELECT customer_id
		FROM rental
		WHERE return_date - INTERVAL '7 DAYS' > rental_date
		);
	COMMIT;
END;
$$

CALL sevenDayFee(7.00);

SELECT *
FROM payment, rental;

--2
CREATE OR REPLACE PROCEDURE make_platinum()
LANGUAGE plpgsql
	AS $$
	BEGIN
	
		UPDATE customer
		SET is_platinum = true
		WHERE customer_id IN(
			SELECT customer_id
			FROM payment
			GROUP BY customer.customer_id, payment.customer_id
			HAVING SUM(amount) > 200.00
		);
		
		UPDATE customer
		SET is_platinum = false
		WHERE customer_id IN(
			SELECT customer_id
			FROM payment
			GROUP BY customer.customer_id, payment.customer_id
			HAVING SUM(amount) < 200.00
		);
		COMMIT;
	END;
$$

CALL make_platinum();

SELECT * 
FROM customer;
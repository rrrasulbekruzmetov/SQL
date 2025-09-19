SELECT *
FROM authors

SELECT *
FROM books

SELECT *
FROM loans

SELECT *
FROM members

-- Intermediate level 

-- Member Activity Dashboard: Total books borrowed per month/year per member. Active vs inactive members.
-- Borrowing patterns over time.


-- Total books borrowed per month/year per member 

SELECT 
m.member_id,
m.name,
YEAR(l.loan_date) AS borrow_year,
MONTH(l.loan_date) AS borrow_month,
COUNT(*) AS total_borrowed
FROM loans l 
JOIN members m 
ON l.member_id = m.member_id
GROUP BY m.member_id, m.name,YEAR (l.loan_date), MONTH(l.loan_date)
ORDER BY m.member_id, borrow_year, borrow_month

-- Active vs inactive members

SELECT 
m.member_id,
m.name,
CASE 
	WHEN COUNT(l.loan_id) > 0 THEN 'Active'
	ELSE 'Inactive'
END AS status,
COUNT(l.loan_id) AS total_loans
FROM members m 
LEFT JOIN loans l 
ON m.member_id = l.member_id
GROUP BY m.member_id, m.name
ORDER BY status DESC, total_loans DESC

-- Borrowing patterns over time.

SELECT 
YEAR(l.loan_date) AS borrow_year,
MONTH(l.loan_date) AS borrow_month,
COUNT(*) AS total_loans
FROM loans l 
GROUP BY YEAR(l.loan_date) , MONTH(l.loan_date)
ORDER BY borrow_year, borrow_month


-- Loan Analytics: Average loan duration per book. Identify popular periods (seasonal analysis).
-- Find overdue loans and members with frequent delays.

-- Average loan duration per book.

SELECT 
b.book_id,
b.title,
AVG(DATEDIFF(day, l.loan_date, l.return_date)) AS avg_loan_days
FROM loans l 
JOIN books b 
ON l.book_id = b.book_id
WHERE l.return_date IS NOT NULL 
GROUP BY b.book_id, b.title
ORDER BY avg_loan_days DESC

-- Identify popular periods (seasonal analysis).

SELECT 
CASE 
WHEN MONTH(l.loan_date) IN (12, 1, 2) THEN 'Winter'
WHEN MONTH(l.loan_date) IN (3, 4, 5) THEN 'Spring'
WHEN MONTH(l.loan_date) IN (6, 7, 8) THEN 'Summer'
WHEN MONTH(l.loan_date) IN (9, 10, 11) THEN 'Autumn'
END AS season,
COUNT(*) AS total_loans
FROM loans l 
GROUP BY 
CASE
WHEN MONTH(l.loan_date) IN (12, 1, 2) THEN 'Winter'
WHEN MONTH(l.loan_date) IN (3, 4, 5) THEN 'Spring'
WHEN MONTH(l.loan_date) IN (6, 7, 8) THEN 'Summer'
WHEN MONTH(l.loan_date) IN (9, 10, 11) THEN 'Autumn'
END 
ORDER BY total_loans DESC

-- Find overdue loans and members with frequent delays.

SELECT 
    l.loan_id,
    l.book_id,
    l.member_id,
    l.loan_date,
    l.return_date,
    DATEADD(DAY, 14, l.loan_date) AS expected_return_date,
    DATEDIFF(DAY, DATEADD(DAY, 14, l.loan_date), ISNULL(l.return_date, GETDATE())) AS days_late
FROM loans l
WHERE (l.return_date IS NULL OR l.return_date > DATEADD(DAY, 14, l.loan_date));

-- Author & Book Analytics: Most popular authors (based on loans). Average loans per book per genre.


-- Most popular authors (based on loans)

SELECT 
a.author_id,
a.name AS author_name,
COUNT(l.loan_id) AS total_loans
FROM loans l 
JOIN books b 
ON l.book_id = b.book_id
JOIN authors a 
ON b.author_id = a.author_id
GROUP BY a.author_id, a.name
ORDER BY total_loans DESC

-- Average loans per book per genre.

SELECT 
b.genre,
AVG(CAST(loans_per_book AS FLOAT)) AS avg_loans_per_book
FROM (
SELECT 
b.book_id,
b.genre,
COUNT(l.loan_id) AS loans_per_book
FROM books b 
LEFT JOIN loans l 
ON b.book_id = l.book_id
GROUP BY b.book_id, b.genre 
) AS sub 
GROUP BY genre 
ORDER BY avg_loans_per_book DESC


-- Integration / Automation: Combine SQL queries with Python or Excel dashboards. Automate reminders for overdue loans.
-- Predict which books will be most borrowed next month (optional ML extension).

-- Automate reminders for overdue loans. 

SELECT 
    l.loan_id,
    l.book_id,
    l.member_id,
    m.name AS member_name,
    m.email,
    l.loan_date,
    l.return_date,
    DATEADD(DAY, 14, l.loan_date) AS expected_return_date,
    DATEDIFF(DAY, DATEADD(DAY, 14, l.loan_date), ISNULL(l.return_date, GETDATE())) AS days_late
FROM loans l
JOIN members m ON l.member_id = m.member_id
WHERE (l.return_date IS NULL OR l.return_date > DATEADD(DAY, 14, l.loan_date));

-- Predict which books will be most borrowed next month (optional ML extension).
SELECT 
    book_id,
    YEAR(loan_date) AS year,
    MONTH(loan_date) AS month,
    COUNT(*) AS borrow_count
FROM loans
GROUP BY book_id, YEAR(loan_date), MONTH(loan_date)
ORDER BY year, month;


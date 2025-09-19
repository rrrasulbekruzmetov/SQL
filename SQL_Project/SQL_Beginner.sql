SELECT *
FROM [loans]

SELECT *
FROM [books]

SELECT *
FROM [members]

SELECT *
FROM [authors]

-- Popular Books Query: Which books are loaned the most?

SELECT 
b.book_id, 
b.title,
COUNT(l.loan_id) AS total_loans
FROM books b 
JOIN loans l 
ON b.book_id = l.book_id
GROUP BY b.book_id, b.title
ORDER BY total_loans DESC

-- Active Members: Members who borrowed the most books.

SELECT 
m.member_id,
m.name,
COUNT(l.loan_id) AS books_borrow
FROM members m 
JOIN loans l
ON m.member_id = l.member_id
GROUP BY m.member_id, m.name
ORDER BY books_borrow DESC

-- Overdue Loans: Find loans where return_date is missing or past due.
-- Kechiktirilgan qarzlarni topish querysini yozamiz.

SELECT 
l.loan_id, 
m.member_id,
m.name AS member_name,
b.book_id,
b.title AS book_title,
l.loan_date,
l.return_date,
DATEADD(DAY, 14, l.loan_date) AS calculated_due_date
FROM loans l
JOIN members m 
ON l.member_id = m.member_id
JOIN books b 
ON l.book_id = b.book_id
WHERE l.return_date IS NULL  AND GETDATE() > DATEADD(DAY, 14, l.loan_date)

-- Author Statistics: Count of books per author. Most borrowed books by author.
-- Har bir muallif necha kitob yozgani va Qaysi muallifning kitoblari eng ko‘p o‘qilgani

SELECT 
a.author_id,
a.name AS author_name,
COUNT(b.book_id) AS total_books
FROM authors a 
LEFT JOIN books b 
ON a.author_id = b.author_id
GROUP BY a.author_id, a.name
ORDER BY total_books DESC 


SELECT 
a.author_id,
a.name AS author_name,
COUNT(l.loan_id) AS total_loans
FROM authors a 
JOIN books b 
ON a.author_id = b.author_id
JOIN loans l 
ON b.book_id = l.book_id
GROUP BY a.author_id, a.name
ORDER BY total_loans DESC

SELECT 
a.author_id,
a.name AS author_name,
COUNT(DISTINCT b.book_id) AS total_books,
COUNT(l.loan_id) AS total_loans
FROM authors a 
LEFT JOIN books b 
ON a.author_id  = b.author_id
LEFT JOIN loans l 
ON b.book_id = l.book_id
GROUP BY a.author_id, a.name
ORDER BY total_loans DESC

-- Genre Insights: Which genre is borrowed the most? Average borrow time per genre. 
-- genre bo‘yicha nechta kitob olingani, har bir janrning kitob qaytarilishigacha qancha kun o‘qilgani

-- Qaysi janr eng ko‘p o‘qilgan 

SELECT 
b.genre,
COUNT(*) AS borrow_count
FROM loans l 
JOIN books b  
ON l.book_id = b.book_id
GROUP BY b.genre  
ORDER BY borrow_count DESC;


-- Har bir janr bo‘yicha o‘rtacha o‘qish vaqti

SELECT 
b.genre,
AVG(DATEDIFF(day, l.loan_date, l.return_date)) AS avg_borrow_days
FROM loans l 
JOIN books b 
ON l.book_id = b.book_id
WHERE l.return_date IS NOT NULL 
GROUP BY b.genre
ORDER BY avg_borrow_days DESC; 

-- yuqoridagi ikkalasini birlashtirib chiqaramiz 

SELECT 
b.genre,
COUNT(*) AS borrow_count,
AVG(DATEDIFF(day, l.loan_date, l.return_date)) AS avg_borrow_days
FROM loans l 
JOIN books b 
ON l.book_id = b.book_id
WHERE l.return_date IS NOT NULL
GROUP BY b.genre
ORDER BY borrow_count DESC 

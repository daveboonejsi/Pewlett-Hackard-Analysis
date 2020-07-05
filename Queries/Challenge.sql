-- queries.sql

--retirement eligibility creating new table to hold info

SELECT emp_no, first_name, last_name
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1925-01-01' AND '1955-12-31')
AND (hire_date	BETWEEN '1985-01-01' AND '1988-12-31');

-- Number of employees retiring
SELECT COUNT(first_name)
FROM employees
WHERE (birth_date BETWEEN '1925-01-01' AND '1955-12-31')
AND (hire_date	BETWEEN '1985-01-01' AND '1988-12-31');

--joining department and managers tables
SELECT d.dept_name
	dm.emp_no,
	dm.from_date,
	dm.to_date,
FROM departments as d
INNER JOIN dept_manager as dm
ON d.dept_no = dm.dept_no
WHERE dm.to_date = ('9999-01-01');

--selecting current employees
SELECT ri.emp_no,
ri.first_name,
ri.last_name,
de.to_date
INTO current_emp
FROM retirement_info as ri
LEFT JOIN dept_emp as de
ON ri.emp_no = de.emp_no	
WHERE de.to_date = ('9999-01-01');

--count by department number
SELECT COUNT (ce.emp_no), de.dept_no
FROM current_emp as ce
LEFT JOIN dept_emp as de
ON ce.emp_no = de.emp_no
GROUP BY de.dept_no
ORDER BY de. dept_no;


--employee list with gender and salary
SELECT e.emp_no,
e.first_name,
e.last_name,
s.salary,
de.to_date
INTO emp_info
FROM employees as e
INNER JOIN salaries as s
	ON (e.emp_no = s.emp_no)
INNER JOIN dept_emp as de
	ON (e.emp_no = de.emp_no)
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (e.hire_date BETWEEN '1985-01-01' AND '1988-12-31')
AND (de.to_date = '9999-01-01');

SELECT * FROM emp_info;

-- list of managers by department
SELECT dm.dept_no,
d.dept_name,
dm.emp_no,
ce.last_name,
ce.first_name,
dm.from_date,
dm.to_date
INTO manager_info
FROM dept_manager as dm
INNER JOIN departments as d
ON (dm.dept_no = d.dept_no)
INNER JOIN current_emp as ce
ON (dm.emp_no = ce.emp_no);

--list of employees by departments	
SELECT ce.emp_no,
ce.first_name,
ce.last_name,
d.dept_name
INTO dept_info
FROM current_emp as ce
INNER JOIN dept_emp AS de
ON (ce.emp_no = de.emp_no)
INNER JOIN departments as d
ON (de.dept_no = d.dept_no);

--list of sales Employees 
SELECT ce.emp_no,
ce.first_name,
ce.last_name,
d.dept_name
INTO sales_info
FROM current_emp as ce
INNER JOIN dept_emp as de
ON (ce.emp_no = de.emp_no)
INNER JOIN departments as d
ON (de.dept_no = d.dept_no)
WHERE d.dept_name = 'Sales';

--list of sales and development
SELECT ce.emp_no,
ce.first_name,
ce.last_name,
d.dept_name
INTO sales_dev
FROM current_emp as ce
INNER JOIN dept_emp as de
ON (ce.emp_no = de.emp_no)
INNER JOIN departments as d
ON (de.dept_no = d.dept_no)
WHERE d.dept_name IN ('Sales', 'Development')
ORDER by ce.emp_no;

SELECT * FROM sales_dev;

-- number of employees retiring by title
SELECT ce.emp_no,
ce.first_name,
ce.last_name,
ti.title,
ti.from_date,
ti.to_date
INTO ret_titles 
FROM current_emp as ce
INNER JOIN titles as ti
ON (ce.emp_no = ti.emp_no)
ORDER BY ce.emp_no;

SELECT * FROM ret_titles
ORDER BY ret_titles.emp_no;

--partition the data to show only the most recent titles per employee
SELECT emp_no,
first_name,
last_name,
to_date,
title
INTO unique_titles
FROM (
	SELECT emp_no,
	first_name,
	last_name,
	to_date,
	title, ROW_NUMBER() OVER
	(PARTITION BY (emp_no) 
	 ORDER BY to_date DESC) rn
	 FROM ret_titles
	 ) tmp WHERE rn = 1
ORDER BY emp_no;

SELECT * FROM unique_titles;

SELECT COUNT(title), title
INTO retiring_titles
FROM unique_titles
GROUP BY title
ORDER BY count DESC;

SELECT * FROM retiring_titles;

--Create a list of employees eligible for potential mentorship
SELECT e.emp_no,
e.first_name,
e.last_name,
e.birth_date,
de.from_date,
de.to_date,
ti.title
INTO mentorship
FROM employees as e
INNER JOIN dept_emp as de
ON (e.emp_no = de.emp_no)
INNER JOIN titles as ti
ON (e.emp_no = ti.emp_no)
WHERE (de.to_date = '9999-01-01')
AND (e.birth_date BETWEEN '1965-01-01' and '1965-12-31')
ORDER BY e.emp_no;

SELECT * FROM mentorship;
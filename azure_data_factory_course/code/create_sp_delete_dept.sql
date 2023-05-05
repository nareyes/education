CREATE PROCEDURE sp_delete_dept
    @p_dept_name VARCHAR(MAX)
AS
BEGIN
    DELETE FROM dbo.Department
	WHERE Dept_Name = @p_dept_name
END
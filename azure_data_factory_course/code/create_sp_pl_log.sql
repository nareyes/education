CREATE PROCEDURE sp_log_pipeline_rundetails
    @p_pipeline_name     VARCHAR(MAX)
    ,@p_pipeline_run_id  VARCHAR(MAX)
    ,@p_trigger_type     VARCHAR(MAX)
AS
BEGIN
	INSERT INTO dbo.PipelineLogs(Name, Run_Id, Trigger_Type) 
	VALUES (@p_pipeline_name, @p_pipeline_run_id, @p_trigger_type)
END
package org.example.model;
import java.util.Date;
public class MealNotification
{
    private int id;
    private String message;
    private String createdBy;
    private Date createdAt;
    private int viewedCount;
    public int getId()
    {
        return id;
    }
    public void setId(int id)
    {
        this.id = id;
    }
    public String getMessage()
    {
        return message;
    }
    public void setMessage(String message)
    {
        this.message = message;
    }
    public String getCreatedBy()
    {
        return createdBy;
    }
    public void setCreatedBy(String createdBy)
    {
        this.createdBy = createdBy;
    }
    public Date getCreatedAt()
    {
        return createdAt;
    }
    public void setCreatedAt(Date createdAt)
    {
        this.createdAt = createdAt;
    }
    public int getViewedCount()
    {
        return viewedCount;
    }
    public void setViewedCount(int viewedCount)
    {
        this.viewedCount = viewedCount;
    }
}
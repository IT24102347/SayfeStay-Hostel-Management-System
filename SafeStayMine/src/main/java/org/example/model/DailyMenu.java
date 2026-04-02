package org.example.model;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class DailyMenu {

    private int id;
    private Date menuDate;
    private String mealType;
    private String itemName;
    private String description;
    private double price;
    private boolean available;
    private String preparedBy;
    private Date createdAt;
    private Date updatedAt;
    private String imagePath;
    private Date orderDeadline;
    private int menuGroup;
    private boolean specialGroup;
    private boolean highlighted;
    private int displayOrder;

    public DailyMenu() {
        this.description = "";
        this.available = true;
        this.menuGroup = 0;
        this.specialGroup = false;
        this.highlighted = false;
        this.displayOrder = 0;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }


    public Date getMenuDate() {
        return menuDate;
    }

    public void setMenuDate(Date menuDate) {
        this.menuDate = menuDate;
    }


    public String getMealType() {
        return mealType;
    }

    public void setMealType(String mealType) {
        this.mealType = mealType;
    }


    public String getItemName() {
        return itemName;
    }

    public void setItemName(String itemName) {
        this.itemName = itemName;
    }


    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }


    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }


    public boolean isAvailable() {
        return available;
    }

    public void setAvailable(boolean available) {
        this.available = available;
    }


    public String getPreparedBy() {
        return preparedBy;
    }

    public void setPreparedBy(String preparedBy) {
        this.preparedBy = preparedBy;
    }


    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }


    public Date getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Date updatedAt) {
        this.updatedAt = updatedAt;
    }


    public String getImagePath() {
        return imagePath;
    }

    public void setImagePath(String imagePath) {
        this.imagePath = imagePath;
    }


    public Date getOrderDeadline() {
        return orderDeadline;
    }

    public void setOrderDeadline(Date orderDeadline) {
        this.orderDeadline = orderDeadline;
    }


    public int getMenuGroup() {
        return menuGroup;
    }

    public void setMenuGroup(int menuGroup) {
        this.menuGroup = menuGroup;
    }


    public boolean isSpecialGroup() {
        return specialGroup;
    }

    public void setSpecialGroup(boolean specialGroup) {
        this.specialGroup = specialGroup;
    }


    public boolean isHighlighted() {
        return highlighted;
    }

    public void setHighlighted(boolean highlighted) {
        this.highlighted = highlighted;
    }


    public int getDisplayOrder() {
        return displayOrder;
    }

    public void setDisplayOrder(int displayOrder) {
        this.displayOrder = displayOrder;
    }


    public boolean isMealSet() {
        return description != null && description.startsWith("SET|");
    }

    public boolean isTeaOrSimpleItem() {
        return !isMealSet();
    }

    public List<String> getParts() {
        List<String> parts = new ArrayList<>();

        if (description == null || description.trim().isEmpty()) {
            return parts;
        }

        String raw = description.trim();

        if (raw.startsWith("SET|")) {
            raw = raw.substring(4);
        } else if (raw.startsWith("ITEM|")) {
            raw = raw.substring(5);
        }

        String[] tokens = raw.split(",");
        for (String token : tokens) {
            if (token != null) {
                String value = token.trim();
                if (!value.isEmpty()) {
                    parts.add(value);
                }
            }
        }

        return parts;
    }

    @Override
    public String toString() {
        return "DailyMenu{" +
                "id=" + id +
                ", menuDate=" + menuDate +
                ", mealType='" + mealType + '\'' +
                ", itemName='" + itemName + '\'' +
                ", description='" + description + '\'' +
                ", price=" + price +
                ", available=" + available +
                ", preparedBy='" + preparedBy + '\'' +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                ", imagePath='" + imagePath + '\'' +
                ", orderDeadline=" + orderDeadline +
                ", menuGroup=" + menuGroup +
                ", specialGroup=" + specialGroup +
                ", highlighted=" + highlighted +
                ", displayOrder=" + displayOrder +
                '}';
    }
}
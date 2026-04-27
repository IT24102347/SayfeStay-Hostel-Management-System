package org.example.model;

public class LaundryRequestItem {
    private int id;
    private int requestId;
    private int itemId;
    private String itemName;
    private int quantity;
    private double pricePerItem;
    private double totalPrice;

    // Constructors
    public LaundryRequestItem() {}

    public LaundryRequestItem(int itemId, String itemName, int quantity, double pricePerItem) {
        this.itemId = itemId;
        this.itemName = itemName;
        this.quantity = quantity;
        this.pricePerItem = pricePerItem;
        this.totalPrice = quantity * pricePerItem;
    }

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getRequestId() { return requestId; }
    public void setRequestId(int requestId) { this.requestId = requestId; }

    public int getItemId() { return itemId; }
    public void setItemId(int itemId) { this.itemId = itemId; }

    public String getItemName() { return itemName; }
    public void setItemName(String itemName) { this.itemName = itemName; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) {
        this.quantity = quantity;
        this.totalPrice = quantity * this.pricePerItem;
    }

    public double getPricePerItem() { return pricePerItem; }
    public void setPricePerItem(double pricePerItem) {
        this.pricePerItem = pricePerItem;
        this.totalPrice = quantity * pricePerItem;
    }

    public double getTotalPrice() { return totalPrice; }
    public void setTotalPrice(double totalPrice) { this.totalPrice = totalPrice; }
}
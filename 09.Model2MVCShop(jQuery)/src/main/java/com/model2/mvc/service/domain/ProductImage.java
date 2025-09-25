// com.model2.mvc.service.domain.ProductImage
package com.model2.mvc.service.domain;

public class ProductImage {
    private int imageNo;
    private int prodNo;
    private String imagePath;
    private Integer sortOrd; // null 허용

    // getters/setters
    public int getImageNo() { return imageNo; }
    public void setImageNo(int imageNo) { this.imageNo = imageNo; }
    public int getProdNo() { return prodNo; }
    public void setProdNo(int prodNo) { this.prodNo = prodNo; }
    public String getImagePath() { return imagePath; }
    public void setImagePath(String imagePath) { this.imagePath = imagePath; }
    public Integer getSortOrd() { return sortOrd; }
    public void setSortOrd(Integer sortOrd) { this.sortOrd = sortOrd; }
}

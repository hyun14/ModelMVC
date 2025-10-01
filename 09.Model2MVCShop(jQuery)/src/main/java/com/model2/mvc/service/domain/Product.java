package com.model2.mvc.service.domain;

import java.sql.Date;
import java.util.List;

public class Product {

	// private String fileName;
	private List<ProductImage> images;
	private String manuDate;
	private int price;
	private String prodDetail;
	private String prodName;
	private int prodNo;
	private Date regDate;
	//private String proTranCode;
	// 추가 필드 : 재고 수량(0 이상)
	private int quantity;

	// 추가 필드 : 판매여부('Y'/'N')
	private String isSell;

	public Product() {
	}

//	public String getProTranCode() {
//		return proTranCode;
//	}
//
//	public void setProTranCode(String proTranCode) {
//		this.proTranCode = proTranCode;
//	}

	public List<ProductImage> getImages() {
		return images;
	}

	public void setImages(List<ProductImage> images) {
		this.images = images;
	}

//	public String getFileName() {
//		return fileName;
//	}
//
//	public void setFileName(String fileName) {
//		this.fileName = fileName;
//	}

	public String getManuDate() {
		return manuDate;
	}

	public void setManuDate(String manuDate) {
		this.manuDate = manuDate;
	}

	public int getPrice() {
		return price;
	}

	public void setPrice(int price) {
		this.price = price;
	}

	public String getProdDetail() {
		return prodDetail;
	}

	public void setProdDetail(String prodDetail) {
		this.prodDetail = prodDetail;
	}

	public String getProdName() {
		return prodName;
	}

	public void setProdName(String prodName) {
		this.prodName = prodName;
	}

	public int getProdNo() {
		return prodNo;
	}

	public void setProdNo(int prodNo) {
		this.prodNo = prodNo;
	}

	public Date getRegDate() {
		return regDate;
	}

	public void setRegDate(Date regDate) {
		this.regDate = regDate;
	}

	public int getQuantity() {
		return quantity;
	}

	public void setQuantity(int quantity) {
		this.quantity = quantity;
	}

	public String getIsSell() {
		return isSell;
	}

	public void setIsSell(String isSell) {
		this.isSell = isSell;
	}

	@Override
	public String toString() {
		return "Product [images=" + images + ", manuDate=" + manuDate + ", price=" + price + ", prodDetail="
				+ prodDetail + ", prodName=" + prodName + ", prodNo=" + prodNo + ", regDate=" + regDate
				+ /* ", proTranCode=" + proTranCode + */", quantity=" + quantity + ", isSell=" + isSell + "]";
	}
}
package com.model2.mvc.service.domain;

import java.sql.Date;

public class Purchase {

	// == Transaction Status Constants ==//
	public static final String TRAN_BEFORE = "BEF";
	public static final String TRAN_SHIPPING = "SHP";
	public static final String TRAN_DELIVERY = "DLV";

	// == Payment Option Constants ==//
	public static final String PAY_CASH = "CSH";
	public static final String PAY_CARD = "CRD";

	private User buyer;
	private String divyAddr;
	private String divyDate;
	private String divyRequest;
	private Date orderDate;
	private String paymentOption;
	private Product purchaseProd;
	private String receiverName;
	private String receiverPhone;
	private String tranCode;
	private int tranNo;
	// 추가 필드 : 구매 수량(1 이상)
	private int sellQuantity;

	public Purchase() {
	}

	public User getBuyer() {
		return buyer;
	}

	public void setBuyer(User buyer) {
		this.buyer = buyer;
	}

	public String getDivyAddr() {
		return divyAddr;
	}

	public void setDivyAddr(String divyAddr) {
		this.divyAddr = divyAddr;
	}

	public String getDivyDate() {
		return divyDate;
	}

	public void setDivyDate(String divyDate) {
		this.divyDate = divyDate;
	}

	public String getDivyRequest() {
		return divyRequest;
	}

	public void setDivyRequest(String divyRequest) {
		this.divyRequest = divyRequest;
	}

	public Date getOrderDate() {
		return orderDate;
	}

	public void setOrderDate(Date orderDate) {
		this.orderDate = orderDate;
	}

	public String getPaymentOption() {
		return paymentOption;
	}

	public void setPaymentOption(String paymentOption) {
		this.paymentOption = paymentOption;
	}

	public Product getPurchaseProd() {
		return purchaseProd;
	}

	public void setPurchaseProd(Product purchaseProd) {
		this.purchaseProd = purchaseProd;
	}

	public String getReceiverName() {
		return receiverName;
	}

	public void setReceiverName(String receiverName) {
		this.receiverName = receiverName;
	}

	public String getReceiverPhone() {
		return receiverPhone;
	}

	public void setReceiverPhone(String receiverPhone) {
		this.receiverPhone = receiverPhone;
	}

	public String getTranCode() {
		return tranCode;
	}

	public void setTranCode(String tranCode) {
		this.tranCode = tranCode;
	}

	public int getTranNo() {
		return tranNo;
	}

	public void setTranNo(int tranNo) {
		this.tranNo = tranNo;
	}

	public int getSellQuantity() {
		return sellQuantity;
	}

	public void setSellQuantity(int sellQuantity) {
		this.sellQuantity = sellQuantity;
	}

	@Override
	public String toString() {
		return "Purchase [buyer=" + buyer + ", divyAddr=" + divyAddr + ", divyDate=" + divyDate + ", divyRequest="
				+ divyRequest + ", orderDate=" + orderDate + ", paymentOption=" + paymentOption + ", purchaseProd="
				+ purchaseProd + ", receiverName=" + receiverName + ", receiverPhone=" + receiverPhone + ", tranCode="
				+ tranCode + ", tranNo=" + tranNo + ", sellQuantity=" + sellQuantity + "]";
	}

	public String getPaymentOptionLabel() {
		if (paymentOption == null)
			return "-";
		switch (paymentOption) {
		case "CSH":
			return "현금";
		case "CRD":
			return "카드";
		default:
			return paymentOption;
		}
	}

	public String getTranStatusLabel() {
		if (tranCode == null || tranCode.trim().isEmpty())
			return "판매중";
		switch (tranCode) {
		case "BEF":
			return "배송전 상태 입니다";
		case "SHP":
			return "현재 배송중 상태 입니다";
		case "DLV":
			return "현재 배송완료 상태 입니다";
		default:
			return tranCode;
		}
	}

	/** divyDate: "yyyyMMdd" -> "yyyy-MM-dd" */
	public String getDivyDateDash() {
		if (divyDate == null)
			return "-";
		String d = divyDate.trim();
		if (d.length() == 8) {
			return d.substring(0, 4) + "-" + d.substring(4, 6) + "-" + d.substring(6, 8);
		}
		return d;
	}

}
package com.model2.mvc.common;

//==>리스트화면을 모델링(추상화/캡슐화)한 Bean 
public class Search {

	/// Field
	private int currentPage;
	private String searchCondition;
	private String searchKeyword;
	private int pageSize;
	private Boolean seeAll;
	// [추가] 거래 상태(tranCode) 필터링을 위한 필드
    private String searchStatus;
	private int endRowNum;
	private int startRowNum;

	/// Constructor
	public Search() {
	}

	/// Method
	public int getPageSize() {
		return pageSize;
	}

	public void setPageSize(int paseSize) {
		this.pageSize = paseSize;
	}

	public int getCurrentPage() {
		return currentPage;
	}

	public void setCurrentPage(int currentPage) {
		this.currentPage = currentPage;
	}

	public String getSearchCondition() {
		return searchCondition;
	}

	public void setSearchCondition(String searchCondition) {
		this.searchCondition = searchCondition;
	}

	public String getSearchKeyword() {
		return searchKeyword;
	}

	public void setSearchKeyword(String searchKeyword) {
		this.searchKeyword = searchKeyword;
	}

	public Boolean getSeeAll() {
		return seeAll;
	}

	public void setSeeAll(Boolean seeAll) {
		this.seeAll = seeAll;
	}
	
	// [추가] searchStatus의 Getter와 Setter
    public String getSearchStatus() {
        return searchStatus;
    }

    public void setSearchStatus(String searchStatus) {
        this.searchStatus = searchStatus;
    }

	// ==> Select Query 시 ROWNUM 마지막 값
	public int getEndRowNum() {
		return getCurrentPage() * getPageSize();
	}

	// ==> Select Query 시 ROWNUM 시작 값
	public int getStartRowNum() {
		return (getCurrentPage() - 1) * getPageSize() + 1;
	}

	@Override
	public String toString() {
		return "Search [currentPage=" + currentPage + ", searchCondition=" + searchCondition + ", searchKeyword="
				+ searchKeyword + ", pageSize=" + pageSize + ", seeAll=" + seeAll + ", searchStatus=" + searchStatus
				+ ", endRowNum=" + endRowNum + ", startRowNum=" + startRowNum + "]";
	}
}
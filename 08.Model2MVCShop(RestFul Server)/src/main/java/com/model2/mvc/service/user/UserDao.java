package com.model2.mvc.service.user;

import java.util.Map;
import com.model2.mvc.common.Search;
import com.model2.mvc.service.domain.User;

/**
 * User 데이터베이스 연동을 위한 인터페이스
 */
public interface UserDao {
	
	/**
	 * 신규 회원을 등록합니다.
	 */
	public void insertUser(User user) throws Exception;

	/**
	 * 특정 회원의 정보를 조회합니다.
	 * @param userId 조회할 회원 ID
	 * @return 조회된 회원 정보
	 */
	public User findUser(String userId) throws Exception;

	/**
	 * 회원 목록을 조회합니다.
	 * @param search 검색 및 페이징 정보
	 * @return 회원 목록과 전체 개수를 포함한 Map
	 */
	public Map<String , Object> getUserList(Search search) throws Exception;

	/**
	 * 회원 정보를 수정합니다.
	 */
	public void updateUser(User user) throws Exception;
	
}
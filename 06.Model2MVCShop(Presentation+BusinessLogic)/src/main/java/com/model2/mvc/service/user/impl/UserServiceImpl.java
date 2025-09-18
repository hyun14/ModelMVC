package com.model2.mvc.service.user.impl;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;

import com.model2.mvc.common.Search;
import com.model2.mvc.service.domain.User;
import com.model2.mvc.service.user.UserDao;
import com.model2.mvc.service.user.UserService;

@Service("userServiceImpl") // @Service 어노테이션 추가
public class UserServiceImpl implements UserService {
	
	@Autowired
	@Qualifier("userDaoImpl")
	private UserDao userDao; // 인터페이스에 의존하도록 변경
	
	public UserServiceImpl() {
		System.out.println(this.getClass());
	}

	public void addUser(User user) throws Exception {
		userDao.insertUser(user);
	}

	public User loginUser(User user) throws Exception {
		// findUser는 UserMapper.getUser를 호출합니다.
		User dbUser = userDao.findUser(user.getUserId());

		// 로그인 실패 시 예외를 발생시키는 비즈니스 로직은 Service에 유지됩니다.
		if (dbUser == null || !dbUser.getPassword().equals(user.getPassword())) {
			// ID가 없거나 패스워드가 틀린 경우
			throw new Exception("아이디 또는 비밀번호가 일치하지 않습니다.");
		}
		
		return dbUser;
	}

	public User getUser(String userId) throws Exception {
		return userDao.findUser(userId);
	}

	public Map<String,Object> getUserList(Search search) throws Exception {
		return userDao.getUserList(search);
	}

	public void updateUser(User user) throws Exception {
		userDao.updateUser(user);
	}

	public boolean checkDuplication(String userId) throws Exception {
		// ID 중복 체크 비즈니스 로직은 Service에 유지됩니다.
		User user = userDao.findUser(userId);
		if (user != null) {
			// 이미 존재하는 사용자
			return false; 
		}
		// 사용 가능한 ID
		return true;
	}
}
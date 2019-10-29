package org.zerock.security;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.zerock.domain.CustomUser;
import org.zerock.domain.MemberVO;
import org.zerock.mapper.MemberMapper;

import lombok.extern.log4j.Log4j;

@Log4j
public class CustomUserDetailService implements UserDetailsService{ //UserDetailsService는 loadUserByUsername() 이라는 추상메소드만 가진다.
	
	@Autowired
	private MemberMapper memberMapper;

	@Override
	public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
		log.warn("Load User By UserName : "+username);
		
		// userName means userid
		
		MemberVO vo = memberMapper.read(username);
		
		log.warn("queried by member mapper : "+vo);
		
		return vo == null ? null : new CustomUser(vo);//membervo -> User 객체를 상속하는 커스텀유저로 변환
	}
	
	
	
}

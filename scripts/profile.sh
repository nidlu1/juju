#!/usr/bin/env bash

#쉬고 있는 profile 찾기: real1이 사용중이면 real2가 쉬고 있고, 반ㄴ대면 rea1이 쉬고 있음.
function find_idle_profile()
{
  RESPONESE_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/profile) #현재 엔진엑스가 바라보고 있는 스프링부트가 정상적으로 수행중인지 확인. 응답값을 HttpStatus로 받음.
  # 정상이면 200, 오류라면 400~503 사이로 발생하니 400이상은 모두 예외로 보고 real2를 현재 profile로 사용.

  if [ ${RESPONSE_CODE} -ge 400 ]; #400보다 크면(즉, 40x/50x 에러 모두 포함
  then
      CURRENT_PROFILE=real2
  else
      CURRENT_PROFILE=$(curl -s http://localhost/profile)
  fi

  if [ ${CURRENT_PROFILE} == real1 ];
  then
      IDLE_PROFILE=real2 #IDLE_PROFILE 엔진엑스와 연결되지 않은 profile. 스프링부트 프로젝트를 이 profile로 연결하기 위해
  else
      IDLE_PROFILE=real1
  fi

  echo "${IDLE_PROFILE}" #bash라는 스크립트는 값을 반환하는 기능이 없음. 그래서 제일 마지막 줄에 echo로 결과를 출력후 클라이언트에서 그 값을 잡아 ($(find_idle_profile))사용한다. 중간에 echo를 사용해선 안됨.
}

#쉬고 있는 profile의 port찾기
function find_idle_port(){
  IDLE_PROFILE=$(find_idle_profile)

  if [ ${IDLE_PROFILE} == real1 ];
  then
    echo "8081"
  else
    echo "8082"
  fi
}
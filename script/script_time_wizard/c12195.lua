-- 엘더 해피 레이디즈
local s,id=GetID()
function s.initial_effect(c)
	-- 소생 제한
	c:EnableReviveLimit()
    -- 소환 조건
	Fusion.AddProcMix(c,true,true,71625222,CARD_HARPIE_LADY_SISTERS)
	-- 다른 방법으로는 특수 소환 불가
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	e3:SetValue(aux.fuslimit)
	c:RegisterEffect(e3)
	-- 타협 소환 조건
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(EFFECT_SPSUMMON_PROC)
	e4:SetRange(LOCATION_EXTRA)
	e4:SetCondition(s.hspcon)
	e4:SetTarget(s.hsptg)
	e4:SetOperation(s.hspop)
	c:RegisterEffect(e4)
    -- 1번 효과
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_CHANGE_CODE)
	e0:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e0:SetValue(CARD_HARPIE_LADY_SISTERS)
	c:RegisterEffect(e0)
	-- 2번 효과
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	e2:SetCountLimit(1)
	c:RegisterEffect(e2)
end
    -- "시간의 마술사", "해피 레이디", "해피 레이디 세자매"의 카드명이 쓰여짐
s.listed_names={71625222, CARD_HARPIE_LADY, CARD_HARPIE_LADY_SISTERS}
    -- "시간의 마술사", "해피 레이디 세자매"을 융합 소재로 함
s.material={71625222, CARD_HARPIE_LADY_SISTERS}
	-- "해피 레이디" 필터
function s.hspfilter1(c,tp,sc)
	return not c:IsOriginalCode(12195) and c:IsCode(CARD_HARPIE_LADY) and c:IsControler(tp) and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0
end
	-- "해피 레이디 세자매" 필터
function s.hspfilter2(c,tp,sc)
	return not c:IsOriginalCode(12195) and c:IsCode(CARD_HARPIE_LADY_SISTERS) and c:IsControler(tp) and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0
end
	-- 통합 필터
function s.hspfilter3(c,tp,sc)
	return not c:IsOriginalCode(12195) and c:IsCode(CARD_HARPIE_LADY_SISTERS,CARD_HARPIE_LADY) and c:IsControler(tp) and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0
end
	-- 덱 / 엑스트라 덱으로 되돌릴 소재가 존재하는지 여부
function s.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.IsExistingMatchingCard(s.hspfilter1,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,3,nil,tp,c)
		or Duel.IsExistingMatchingCard(s.hspfilter2,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil,tp,c)
	--return Duel.CheckReleaseGroup(tp,s.hspfilter,1,false,1,true,c,tp,nil,false,nil,tp,c)
end
	-- 1장 또는 3장
function s.rescon(sg,e,tp,mg)
	return (#sg==1 and sg:IsExists(Card.IsCode,1,nil,CARD_HARPIE_LADY_SISTERS))
		or (#sg==3 and sg:IsExists(Card.IsCode,3,nil,CARD_HARPIE_LADY))
end
	-- 덱 / 엑스트라 덱으로 되돌릴 몬스터를 지정
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	--local g=Duel.SelectReleaseGroup(tp,s.hspfilter,1,1,false,true,true,c,nil,nil,false,nil,tp,c)
	local rg=Duel.GetMatchingGroup(s.hspfilter3,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil,tp,c)
	local g=aux.SelectUnselectGroup(rg,e,tp,1,3,s.rescon,1,tp,HINTMSG_TODECK,s.rescon,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
	return true
	end
	return false
end
	-- 타협 소환 처리
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST|REASON_MATERIAL)
	g:DeleteGroup()
end

function s.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Destroy(g,REASON_EFFECT)
	end
end
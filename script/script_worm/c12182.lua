-- W성운핵
local s,id=GetID()
function s.initial_effect(c)
	-- 1번 효과
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_BATTLE_PHASE|TIMING_BATTLE_STEP_END|TIMING_BATTLE_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- 2번 효과
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(aux.SelfBanishCost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
    -- "웜"의 테마명이 쓰여짐
s.listed_series = {0x3e}
	-- "웜 제로"의 카드명이 쓰여짐
s.listed_names = {74506079}
	-- 1번 효과
function s.thfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsMonster() and c:IsAbleToHand()
end
function s.wormfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsSetCard(0x3e) and c:IsFacedown()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 서치 필터
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	-- 리버스 필터
	local b2=Duel.IsExistingMatchingCard(s.wormfilter,tp,LOCATION_MZONE,0,1,nil,e,tp)
	if chk==0 then return b1 or b2 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_POSITION,nil,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 서치 필터
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	-- 리버스 필터
	local b2=Duel.IsExistingMatchingCard(s.wormfilter,tp,LOCATION_MZONE,0,1,nil,e,tp)
	-- 웜 제로 존재 여부
	local zero=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,74506079),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	if b1 and b2 and zero and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
		-- 서치 
		s.tohandop(e,tp,eg,ep,ev,re,r,rp)
		-- 리버스
		s.reverseop(e,tp,eg,ep,ev,re,r,rp)
	else 
		-- 하나 고르고 적용
		op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,1)},
			{b2,aux.Stringid(id,2)})
		if op==1 then
			s.tohandop(e,tp,eg,ep,ev,re,r,rp)
		elseif op == 2 then
			s.reverseop(e,tp,eg,ep,ev,re,r,rp)
		end
	end
end
function s.tohandop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.reverseop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,s.wormfilter,tp,LOCATION_MZONE,0,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.ChangePosition(g,Duel.SelectPosition(tp,g:GetFirst(),POS_FACEUP_ATTACK+POS_FACEUP_DEFENSE))
	end
end
	-- 2번 효과
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_REPTILE) and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
	end
end
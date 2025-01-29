-- 다크 트랜스폼
local s,id=GetID()
function s.initial_effect(c)
	-- 1번 효과
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 2번 효과
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DESTROY)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_DUEL)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCost(aux.bfgcost)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.thcond)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
    -- "가디언 에아토스", "가디언 데스사이스"의 카드명이 쓰여짐
s.listed_names = {34022290, 18175965}
function s.spcfilter(c)
	return c:GetEquipCount()>0 and c:IsCode(34022290)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.spcfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.mygrave(c)
	return c:IsMonster() and c:IsAbleToRemove()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return #Duel.GetMatchingGroup(s.mygrave,tp,LOCATION_GRAVE,0,nil)>0
	or #Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)>0 end
	local g1=Duel.GetMatchingGroup(s.mygrave,tp,LOCATION_GRAVE,0,nil)
	local g2=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
	g1:AddCard(g2)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,#g1,PLAYER_ALL,LOCATION_ONFIELD+LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g1=Duel.GetMatchingGroup(s.mygrave,tp,LOCATION_GRAVE,0,nil)
	local g2=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
	g1:AddCard(g2)
	if c:IsRelateToEffect(e) and #g1>0 then
		Duel.Remove(g1,POS_FACEUP,REASON_EFFECT)
	end
end
function s.filter(c,tp)
	return c:IsControler(tp) and c:IsMonster()
end
function s.thcond(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil,tp) 
	and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
function s.eatosfilter(c)
	return c:IsCode(34022290)
end
function s.desfilter(c)
	return c:IsCode(18175965) and c:IsAbleToHand()
end
function s.mygrave2(c)
	return c:IsMonster()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.eatosfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil)
	and Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g1=Duel.SelectMatchingCard(tp,s.eatosfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	if #g1>0 and Duel.Destroy(g1,REASON_EFFECT) then 
		local g2=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
		if #g2>0 and Duel.SendtoHand(g2,nil,REASON_EFFECT) then
			Duel.ConfirmCards(1-tp,g2)
			local g=Duel.GetMatchingGroup(s.mygrave2,tp,LOCATION_GRAVE,0,nil)
			if #g>0 then
				Duel.SendtoGrave(g,REASON_EFFECT+REASON_RETURN)
			end
		end
	end
end
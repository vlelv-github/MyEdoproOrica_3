-- W성운폭발
local s,id=GetID()
function s.initial_effect(c)
	-- 1번 효과
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 2번 효과
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
	-- "웜 제로"의 카드명이 쓰여짐
s.listed_names = {74506079}

function s.faceup(c)
	return c:IsFaceup() and c:IsCanTurnSet() and not c:IsCode(74506079)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.faceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return #g > 0 end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.faceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g>0 then
		local ct=Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabel(ct)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetOperation(s.spop)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_REPTILE)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	Debug.Message(ct)
	if not (ct>0) then return false end
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,ct,nil,e,tp)
	if #g > 0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.thfilter(c)
	return c:IsCode(90075978) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		aux.ToHandOrElse(tc,tp,
		function(tc) return tc:IsSSetable() end,
		function(tc) Duel.SSet(tp,tc) end,
		aux.Stringid(id,2)
	)
	end
end

-- 매지션즈 실크햇
local s,id=GetID()
function s.initial_effect(c)
	-- 발동
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)

	-- 1번 효과
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.negcon)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
end
    -- "블랙 매지션", "블랙 매지션 걸"의 카드명이 쓰여짐
s.listed_names = {CARD_DARK_MAGICIAN, CARD_DARK_MAGICIAN_GIRL}

function s.magifilter(c)
	return c:IsCode(CARD_DARK_MAGICIAN,CARD_DARK_MAGICIAN_GIRL)
		and c:GetSequence()<5 and not c:IsType(TYPE_TOKEN+TYPE_LINK)
end
function s.magifilter2(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_SPELLCASTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
function s.spcheck(sg,e,tp)
	return sg:GetClassCount(Card.GetCode)==2
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and Duel.IsChainDisablable(ev) and (re:IsActiveType(TYPE_SPELL) or re:IsActiveType(TYPE_MONSTER))
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.magifilter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
	if chk==0 then return Duel.IsExistingMatchingCard(s.magifilter,tp,LOCATION_MZONE,0,1,nil)
		and aux.SelectUnselectGroup(g,e,tp,2,2,s.spcheck,0)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	local g0=Duel.GetMatchingGroup(s.magifilter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=Duel.SelectMatchingCard(tp,s.magifilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if not tc or tc:IsImmuneToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=aux.SelectUnselectGroup(g0,e,tp,2,2,s.spcheck,1,tp,HINTMSG_SPSUMMON)
	if tc:IsFaceup() then
		if tc:IsHasEffect(EFFECT_LIGHT_OF_INTERVENTION) then Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
		else
			Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
			tc:ClearEffectRelation()
		end
	end
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
	Duel.ConfirmCards(1-tp,sg)
	sg:AddCard(tc)
	Duel.ShuffleSetCard(sg)
	Duel.BreakEffect()
	local ch=sg:Select(1-tp,1,1,nil):GetFirst()
	Duel.HintSelection(ch)
	if Duel.SendtoHand(ch,nil,REASON_EFFECT) then
		Duel.ConfirmCards(1-tp,sg)
		if not ch:IsCode(CARD_DARK_MAGICIAN, CARD_DARK_MAGICIAN_GIRL) and Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
			Duel.Destroy(eg,REASON_EFFECT)
		end
	end
	sg:RemoveCard(ch)
	sg:KeepAlive()
	Duel.ChangePosition(sg,POS_FACEUP_ATTACK)
end
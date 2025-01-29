-- 갓 웜
local s,id=GetID()
function s.initial_effect(c)
    -- 소생 제한
    c:EnableReviveLimit()
	-- 소환 조건
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_REPTILE),3,3)
    -- 1번 효과
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
    -- 2번 효과
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetDescription(aux.Stringid(id,1))
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.indtg)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
    -- 3번 효과
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_POSITION+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(aux.NOT(s.quickcon))
	e3:SetTarget(s.postg)
	e3:SetOperation(s.posop)
	c:RegisterEffect(e3)
    -- 3번 효과 (프리 체인)
    local e4=e3:Clone()
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e4:SetCondition(s.quickcon)
	c:RegisterEffect(e4)
end
    -- "웜"의 테마명이 쓰여짐
s.listed_series = {0x3e}
    -- "웜 제로"의 카드명이 쓰여짐
s.listed_names = {74506079}

function s.thfilter(c)
	return c:IsCode(90075978,12179,12182,12183) and c:IsAbleToHand()
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.indtg(e,c)
	local oc=e:GetHandler()
	return (c:IsRace(RACE_REPTILE) and oc:GetLinkedGroup():IsContains(c))
end

function s.quickcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,74506079),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
function s.desfilter(c,lv)
    return c:GetLevel() > lv and c:IsFaceup()
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFacedown() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFacedown,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectTarget(tp,Card.IsFacedown,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
    Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_MZONE)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.ChangePosition(tc,Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK+POS_FACEUP_DEFENSE)) and tc:IsLevelAbove(1) then
		local lv=tc:GetLevel()
        local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil,lv)
        if #g > 0 then 
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
            local tg=g:Select(tp,1,1,nil)
            if #tg==0 then return end
            Duel.HintSelection(tg,true)
            Duel.BreakEffect()
		    Duel.Destroy(tg,REASON_EFFECT)
        end
	end
end
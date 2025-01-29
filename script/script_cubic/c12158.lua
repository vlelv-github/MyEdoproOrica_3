-- 방계멸빈
local s,id=GetID()
function s.initial_effect(c)
	-- 패에서도 발동 가능
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e3:SetCondition(s.handcon)
	c:RegisterEffect(e3)

    -- 1번 효과
    local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_COUNTER)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

    -- 2번 효과
    local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
	-- "방계" 테마명이 쓰여짐
s.listed_series = {0xe3}
	-- "방계윤 비잠"의 카드명이 쓰여짐
s.listed_names = {15610297}

function s.handcon(e)
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandler():GetControler(),LOCATION_MZONE,0,1,nil)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe3)
end
function s.vijamfilter(c,e,tp)
    return c:IsCode(15610297) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.desrescon(maxc)
	return function(sg,e,tp,mg)
		local ct1=sg:FilterCount(Card.IsControler,nil,tp)
		local ct2=#sg-ct1
		return ct1==ct2,ct1>maxc or ct2>maxc
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.vijamfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end

    -- 상대 필드의 앞면 표시 몬스터의 수까지, 묘지의 비잠을 선택
    local opct=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local tg1=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.vijamfilter),tp,LOCATION_GRAVE,0,1,#opct,nil,e,tp)
    -- 카운터를 놓을 상대 필드의 앞면 표시 몬스터를 선택
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local tg2=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,#tg1,nil)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tg1,#tg1,0,0)
    tg1:Merge(tg2)
    Duel.SetTargetCard(tg1)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,tg2,#tg2,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	local g=Duel.GetTargetCards(e)
    local g1=g:Filter(Card.IsControler,nil,tp)
    local g2=g:Filter(Card.IsControler,nil,1-tp)

	if #g1>0 and Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP) then
		if #g2>0 then
            for ac in aux.Next(g2) do
                if ac:IsFaceup() then
                    ac:AddCounter(0x1038,1)
                    local e1=Effect.CreateEffect(c)
                    e1:SetType(EFFECT_TYPE_SINGLE)
                    e1:SetCode(EFFECT_CANNOT_ATTACK)
                    e1:SetCondition(s.condition)
                    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                    ac:RegisterEffect(e1)
                    local e2=e1:Clone()
                    e2:SetCode(EFFECT_DISABLE)
                    ac:RegisterEffect(e2)
                end
            end
        end
	end
end
function s.condition(e)
	return e:GetHandler():GetCounter(0x1038)>0
end


function s.filter(c)
    return c:IsFaceup() and c:IsSetCard(0xe3) and not c:IsCode(id)
end
function s.thfilter(c)
    return c:IsSetCard(0xe3) and c:IsMonster()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_REMOVED,0,3,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_REMOVED,0,3,3,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SEARCH+CATEGORY_TOHAND,nil,0,tp,1)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local td=tg:Filter(Card.IsRelateToEffect,nil,e)
	if not tg or #td<=0 then return end
	Duel.SendtoDeck(td,nil,0,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct>0 then
		local thca=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
        if #thca>0 then
            Duel.SendtoHand(thca,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,thca)
        end
	end
end

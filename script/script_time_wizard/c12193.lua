-- 타임 매직
local s,id=GetID()
function s.initial_effect(c)
	-- 1번 효과
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
    -- 코인 토스를 실행하는 효과를 가짐
s.toss_coin=true
    -- "시간의 마술사"의 카드명이 쓰여짐
s.listed_names={71625222}
function s.costfilter(c)
    return c:IsRace(RACE_SPELLCASTER) and c:IsLevelAbove(1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.costfilter,1,false,nil,nil) end
	local sg=Duel.SelectReleaseGroupCost(tp,s.costfilter,1,1,false,nil,nil)
    e:SetLabel(sg:GetFirst():GetCode())
	Duel.Release(sg,REASON_COST)
end
function s.filter(c,e,tp)
    return (c:IsMonster() and c:IsType(TYPE_FUSION) and c:ListsCode(71625222)) or c:IsCode(26273196)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
    Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
function s.disfilter(c)
	return (c:IsFaceup() or c:IsType(TYPE_TRAPMONSTER)) and not (c:IsType(TYPE_NORMAL) and c:GetOriginalType()&TYPE_NORMAL>0)
end
function s.righteff(e,tp,eg,ep,ev,re,r,rp)
    -- 맞힌 경우
    local c=e:GetHandler()
    local g1=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
    if #g1==0 then return end
    local ng=g1:Filter(s.disfilter,nil)
    for nc in aux.Next(ng) do
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        nc:RegisterEffect(e1)
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD)
        nc:RegisterEffect(e2)
        if nc:IsType(TYPE_TRAPMONSTER) then
            local e3=Effect.CreateEffect(c)
            e3:SetType(EFFECT_TYPE_SINGLE)
            e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
            e3:SetReset(RESET_EVENT+RESETS_STANDARD)
            nc:RegisterEffect(e3)
        end
        if nc:IsMonster() then
            local e4=Effect.CreateEffect(c)
            e4:SetType(EFFECT_TYPE_SINGLE)
            e4:SetCode(EFFECT_SET_ATTACK_FINAL)
            e4:SetValue(nc:GetAttack()/2)
            e4:SetReset(RESET_EVENT+RESETS_STANDARD)
            nc:RegisterEffect(e4)
            local e5=Effect.CreateEffect(c)
            e5:SetType(EFFECT_TYPE_SINGLE)
            e5:SetCode(EFFECT_SET_DEFENSE_FINAL)
            e5:SetValue(nc:GetDefense()/2)
            e5:SetReset(RESET_EVENT+RESETS_STANDARD)
            nc:RegisterEffect(e5)
        end
    end
end
function s.wrongeff(e,tp,eg,ep,ev,re,r,rp)
    -- 맞히지 못한 경우
    local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,0,nil)
    if #g>0 then
        Duel.Destroy(g,REASON_EFFECT)
    end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local sg=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	tc:SetMaterial(nil)
	if Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)~=0 then
        tc:CompleteProcedure()
        Duel.BreakEffect()
       
        if sg==71625222 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then 
            local op=Duel.SelectEffect(tp,
            {true, aux.Stringid(id,1)},
            {true, aux.Stringid(id,2)}
            )
            if op==1 then
                s.righteff(e,tp,eg,ep,ev,re,r,rp)
            elseif op==2 then
                s.wrongeff(e,tp,eg,ep,ev,re,r,rp)
            end
        else
            if Duel.CallCoin(tp) then
                s.righteff(e,tp,eg,ep,ev,re,r,rp)
            else
                s.wrongeff(e,tp,eg,ep,ev,re,r,rp)
            end
        end
	end
end
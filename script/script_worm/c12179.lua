-- W성운유기생명체
local s,id=GetID()
function s.initial_effect(c)
    -- 카운터 사용
    c:EnableCounterPermit(0xf)
    -- 카운터는 최대 6개까지
    c:SetCounterLimit(0xf,6)
    -- 발동
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- 1번 효과
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetTarget(function(e,c) return c:IsRace(RACE_REPTILE) end)
	e1:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_EXTRA_SET_COUNT)
	c:RegisterEffect(e2)
    -- 2번 효과
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetOperation(s.acop)
	c:RegisterEffect(e3)
    local e4=e3:Clone()
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e4)
    local e5=e3:Clone()
    e5:SetCode(EVENT_FLIP)
    c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_CHANGE_POS)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCondition(s.spcon1)
	e6:SetOperation(s.acop2)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EVENT_MSET)
	e7:SetCondition(s.spcon2)
	c:RegisterEffect(e7)
	local e8=e6:Clone()
	e8:SetCode(EVENT_SPSUMMON_SUCCESS)
	e8:SetCondition(s.spcon2)
	c:RegisterEffect(e8)

    -- 융합 소환 효과
    local e9=Effect.CreateEffect(c)
    e9:SetCategory(CATEGORY_FUSION_SUMMON+CATEGORY_SPECIAL_SUMMON)
    e9:SetType(EFFECT_TYPE_IGNITION)
    e9:SetRange(LOCATION_SZONE)
    e9:SetCost(s.cost)
    e9:SetTarget(s.target)
    e9:SetOperation(s.operation)
    c:RegisterEffect(e9)

end
    -- "웜"의 테마명이 쓰여짐
s.listed_series = {0x3e}
    -- 웜 카운터를 놓는 효과를 가짐
s.counter_place_list={0xf}

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToGraveAsCost() and c:GetCounter(0xf)>1 end
    e:SetLabel(c:GetCounter(0xf))
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local params = {
        fusfilter = aux.FilterBoolFunction(Card.IsRace,RACE_REPTILE),
        extrafil = s.fextra,
        mincount = 2,
        maxcount = e:GetHandler():GetCounter(0xf),
        extratg=s.extratg
    }
    return Fusion.SummonEffTG(params)(e,tp,eg,ep,ev,re,r,rp,chk)
    --return true
    
    -- if chk==0 then return Fusion.SummonEffTG(params) end
    
    -- Debug.Message()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local params = {
        fusfilter = aux.FilterBoolFunction(Card.IsRace,RACE_REPTILE),
        extrafil = s.fextra,
        mincount = 2,
        maxcount =e:GetLabel(),
        extratg=s.extratg
    }
    Fusion.SummonEffOP(params)(e,tp,eg,ep,ev,re,r,rp)
end
function s.fextra(e,tp,mg)
    return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToGrave),tp,LOCATION_DECK,0,nil)
end


function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,0,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_DECK)
end







function s.acop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(aux.FaceupFilter(Card.IsRace,RACE_REPTILE),1,nil) then
        local ct=eg:FilterCount(aux.FaceupFilter(Card.IsRace,RACE_REPTILE),nil)
		e:GetHandler():AddCounter(0xf,ct)
	end
end
function s.acop2(e,tp,eg,ep,ev,re,r,rp)
    local ct=eg:FilterCount(Card.IsFacedown,nil)
    e:GetHandler():AddCounter(0xf,ct)
end
function s.filter1(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsFacedown() and c:IsControler(tp)
end
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter1,1,nil,tp)
end
function s.filter2(c,tp)
	return c:IsFacedown() and c:IsControler(tp)
end
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter2,1,nil,tp)
end
    -- 3번 효과

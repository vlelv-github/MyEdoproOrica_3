-- 초마도대현자-사우전드 세이지
local s,id=GetID()
function s.initial_effect(c)
	-- 소생 제한
	c:EnableReviveLimit()
    -- 소환 조건
	Fusion.AddProcMix(c,true,true,88819587,{71625222,s.ffilter})
    -- 1번 효과
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_CHANGE_CODE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetValue(CARD_DARK_MAGICIAN)
	c:RegisterEffect(e0)
    -- 2번 효과
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EFFECT_DESTROY_REPLACE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTarget(s.reptg)
    e1:SetValue(function(e,_c) return s.repfilter(_c,e:GetHandlerPlayer()) end)
    c:RegisterEffect(e1)
    -- 3번 효과
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_RELEASE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) end)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
    -- "시간의 마술사", "블랙 매지션"의 카드명이 쓰여짐
s.listed_names={71625222, CARD_DARK_MAGICIAN}
    -- "시간의 마술사", "블랙 매지션"을 융합 소재로 함
s.material={71625222, CARD_DARK_MAGICIAN}

function s.ffilter(c,fc,sumtype,tp)
	return c:IsRace(RACE_SPELLCASTER,fc,sumtype,tp)
end
function s.repfilter(c,tp)
	return c:IsControler(tp) and c:IsOnField() and c:IsReason(REASON_BATTLE|REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.rmvfilter(c)
	return c:IsSpell() and c:IsAbleToRemove()
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp) and Duel.IsExistingMatchingCard(s.rmvfilter,tp,LOCATION_GRAVE,0,1,nil) end
	if Duel.SelectEffectYesNo(tp,c,96) then
		local g=Duel.SelectMatchingCard(tp,s.rmvfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		return true
	else return false end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
    Duel.SetPossibleOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
function s.spellfilter1(c)
    return c:IsSpell() and c:IsDiscardable()
end
function s.spellfilter2(c)
    return c:IsSpell() and c:IsSSetable()
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
    local g1=Duel.GetMatchingGroup(s.spellfilter1,tp,LOCATION_HAND,0,nil)
    local g2=Duel.GetMatchingGroup(s.spellfilter2,tp,LOCATION_DECK,0,nil)
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0
        and #g1>0 and #g2>0 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
        if Duel.DiscardHand(tp,s.spellfilter1,1,1,REASON_EFFECT+REASON_DISCARD,nil) > 0 then 
            Duel.SSet(tp,g2:Select(tp,1,1,nil))
        end
	end
end
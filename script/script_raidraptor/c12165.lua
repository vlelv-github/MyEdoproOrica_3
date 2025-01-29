-- RR(레이드 랩터즈)-포스 팔콘
local s,id=GetID()
function s.initial_effect(c)
    -- 소환 조건
	Xyz.AddProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- 1번 효과
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
    -- 2번 효과
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
    e2:SetCost(s.descost)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
    -- "RR(레이드 랩터즈)", "RUM(랭크 업 매직)"의 테마명이 쓰여짐
s.listed_series = {SET_RAIDRAPTOR, SET_RANK_UP_MAGIC}

function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.thfilter(c)
	return c:IsSetCard(SET_RANK_UP_MAGIC) and c:IsSpell() and c:IsAbleToHand()
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

function s.desfilter(c,tp)
	return c:IsRace(RACE_WINGEDBEAST) and c:IsAbleToRemoveAsCost() --and Duel.GetMZoneCount(tp,c)>0
		and aux.SpElimFilter(c,true)
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),tp)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_COST) and re:IsActivated() and c:IsPreviousLocation(LOCATION_OVERLAY)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local b1=Duel.GetMZoneCount(tp,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
    local b2=Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
    if chk==0 then return b1 or b2 or b3 or b4 end
    local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)}
    )
    e:SetLabel(op)
    if op==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
    else
        e:SetCategory(CATEGORY_DESTROY)
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,0)
    end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
    local c=e:GetHandler()
	if op==1 then
		if Duel.GetMZoneCount(tp,c)>0 then 
            Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
        end
	else
		local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
        if #g>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local sg=g:Select(tp,1,1,nil):GetFirst()
			Duel.HintSelection(sg,true)
			if Duel.Destroy(sg,REASON_EFFECT)~=0 and sg:IsMonster() and sg:IsControler(1-tp) then 
                Duel.BreakEffect()
                Duel.Damage(1-tp,sg:GetAttack(),REASON_EFFECT)
            end
		end
    end
end

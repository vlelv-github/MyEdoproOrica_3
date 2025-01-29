-- 성령의 오페라
local s,id=GetID()
function s.initial_effect(c)
	-- 1번 효과
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 2번 효과 (내성)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTarget(s.immtg)
	e2:SetValue(s.immval)
	c:RegisterEffect(e2)
	-- 2번 효과 (무효 효과)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCondition(s.ngcon)
	e3:SetCost(s.ngcost)
	e3:SetTarget(s.ngtg)
	e3:SetOperation(s.ngop)
	-- 2번 효과 (효과 부여)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(s.immtg)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
	-- 3번 효과
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e5:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCondition(s.condition)
	e5:SetTarget(s.rmtarget)
	e5:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e5:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e5)
end
    -- "가디언 에아토스", "가디언 데스사이스", "성령의 오페라"의 카드명이 쓰여짐
s.listed_names = {34022290, 18175965, id}
    -- "가디언"의 테마명이 쓰여짐
s.listed_series = {0x52}
	-- 1번 효과
function s.filter(c)
	return c:IsSetCard(0x52) and c:IsMonster() and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
	-- 2번 효과
function s.immtg(e,c)
	-- "가디언 에아토스"
	if c:IsCode(34022290) then return true end
	-- 몬스터에 장착되어 있는 카드중에서, 자신에게 카드명이 쓰여진 카드를 장착하고 있는지 확인
	local equip_cards = c:GetEquipGroup()
	if not equip_cards or #equip_cards == 0 then return false end
	for eqc in aux.Next(equip_cards) do
		if c:ListsCode(eqc:GetCode()) then 
			return true
		end
	end
end
function s.immval(e,te)
	return te:GetOwnerPlayer()==1-e:GetHandlerPlayer() and te:IsActivated()
end

function s.ngcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and re:IsMonsterEffect()
		and Duel.IsChainNegatable(ev) and rp~=tp
end
function s.ngfilter(c)
	return c:IsAbleToGraveAsCost()
end
function s.ngcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetEquipGroup():IsExists(s.ngfilter,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=c:GetEquipGroup():FilterSelect(tp,s.ngfilter,1,1,nil,tp)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.ngtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) and re:GetHandler():IsDestructable() then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.ngop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
	-- 3번 효과
function s.eatosfilter(c)
	return c:IsCode(34022290) and c:IsFaceup()
end
function s.rmtarget(e,c)
	return c:IsMonster() and Duel.IsPlayerCanRemove(e:GetHandlerPlayer(),c)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.eatosfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil) 
end

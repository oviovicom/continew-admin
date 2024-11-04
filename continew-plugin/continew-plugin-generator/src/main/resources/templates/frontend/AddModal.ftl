<template>
  <a-modal
    v-model:visible="visible"
    :title="title"
    :mask-closable="false"
    :esc-to-close="false"
    :modal-style="{ maxWidth: '520px' }"
    width="90%"
    @before-ok="save"
    @close="reset"
  >
    <GiForm ref="formRef" v-model="form" :options="options" :columns="columns" />
  </a-modal>
</template>

<script setup lang="ts">
import { Message } from '@arco-design/web-vue'
import { get${classNamePrefix}, add${classNamePrefix}, update${classNamePrefix} } from '@/apis/${apiModuleName}/${apiName}'
import { type Columns, GiForm, type Options } from '@/components/GiForm'
import { useForm } from '@/hooks'
import { useDict } from '@/hooks/app'

const emit = defineEmits<{
  (e: 'save-success'): void
}>()

const dataId = ref('')
const isUpdate = computed(() => !!dataId.value)
const title = computed(() => (isUpdate.value ? '修改${businessName}' : '新增${businessName}'))
const formRef = ref<InstanceType<typeof GiForm>>()

<#if hasDictField>
const { <#list dictCodes as dictCode>${dictCode}<#if dictCode_has_next>,</#if></#list> } = useDict(<#list dictCodes as dictCode>'${dictCode}'<#if dictCode_has_next>,</#if></#list>)
</#if>

const options: Options = {
  form: {},
  btns: { hide: true }
}

const { form, resetForm } = useForm({
  // todo 待补充
})

const columns = computed<Columns<typeof form>>(() => [
<#list fieldConfigs as fieldConfig>
  <#if fieldConfig.showInForm>
  {
    label: '${fieldConfig.comment}',
    field: '${fieldConfig.fieldName}',
    <#if fieldConfig.formType = 'INPUT'>
    type: 'input',
    <#elseif fieldConfig.formType = 'TEXT_AREA'>
    type: 'textarea',
    <#elseif fieldConfig.formType = 'DATE'>
    type: 'date-picker',
    <#elseif fieldConfig.formType = 'DATE_TIME'>
    type: 'time-picker',
    <#elseif fieldConfig.formType = 'INPUT_NUMBER'>
    type: 'input-number', 
    <#elseif fieldConfig.formType = 'INPUT_PASSWORD'>
    type: 'input-password',
    <#elseif fieldConfig.formType = 'SWITCH'>
    type: 'switch',
    <#elseif fieldConfig.formType = 'CHECK_BOX'>
    type: 'check-group',
   	<#elseif fieldConfig.formType = 'TREE_SELECT'>
    type: 'tree-select',
    <#elseif fieldConfig.formType = 'SELECT'>
    type: 'select', 
    <#elseif fieldConfig.formType = 'RADIO'>
    type: 'radio-group'
    </#if>
    <#if fieldConfig.dictCode?? && fieldConfig.dictCode != ''>
    options: ${fieldConfig.dictCode},
    </#if>
    <#if fieldConfig.isRequired>
    rules: [{ required: true, message: '请输入${fieldConfig.comment}' }]
    </#if>
  },
  </#if>
</#list>
])

// 重置
const reset = () => {
  formRef.value?.formRef?.resetFields()
  resetForm()
}

const visible = ref(false)
// 新增
const onAdd = () => {
  reset()
  dataId.value = ''
  visible.value = true
}

// 修改
const onUpdate = async (id: string) => {
  reset()
  dataId.value = id
  const res = await get${classNamePrefix}(id)
  Object.assign(form, res.data)
  visible.value = true
}

// 保存
const save = async () => {
  try {
    const isInvalid = await formRef.value?.formRef?.validate()
    if (isInvalid) return false
    if (isUpdate.value) {
      await update${classNamePrefix}(form, dataId.value)
      Message.success('修改成功')
    } else {
      await add${classNamePrefix}(form)
      Message.success('新增成功')
    }
    emit('save-success')
    return true
  } catch (error) {
    return false
  }
}

defineExpose({ onAdd, onUpdate })
</script>

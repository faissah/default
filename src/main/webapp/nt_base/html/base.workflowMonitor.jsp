<%@ page import="org.jahia.services.workflow.WorkflowService" %>
<%@ page import="org.jahia.services.workflow.HistoryWorkflow" %>
<%@ page import="java.util.List" %>
<%@ page import="org.jahia.services.workflow.HistoryWorkflowTask" %>
<%@ page import="java.util.Locale" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="ui" uri="http://www.jahia.org/tags/uiComponentsLib" %>
<%@ taglib prefix="jcr" uri="http://www.jahia.org/tags/jcr" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="template" uri="http://www.jahia.org/tags/templateLib" %>
<%@ taglib prefix="uiComponents" uri="http://www.jahia.org/tags/uiComponentsLib" %>
<%@ taglib prefix="query" uri="http://www.jahia.org/tags/queryLib" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="workflow" uri="http://www.jahia.org/tags/workflow" %>
<%@ taglib prefix="functions" uri="http://www.jahia.org/tags/functions" %>
<%--@elvariable id="currentNode" type="org.jahia.services.content.JCRNodeWrapper"--%>
<%--@elvariable id="propertyDefinition" type="org.jahia.services.content.nodetypes.ExtendedPropertyDefinition"--%>
<%--@elvariable id="type" type="org.jahia.services.content.nodetypes.ExtendedNodeType"--%>
<%--@elvariable id="out" type="java.io.PrintWriter"--%>
<%--@elvariable id="script" type="org.jahia.services.render.scripting.Script"--%>
<%--@elvariable id="scriptInfo" type="java.lang.String"--%>
<%--@elvariable id="workspace" type="java.lang.String"--%>
<%--@elvariable id="renderContext" type="org.jahia.services.render.RenderContext"--%>
<%--@elvariable id="currentResource" type="org.jahia.services.render.Resource"--%>
<%--@elvariable id="url" type="org.jahia.services.render.URLGenerator"--%>

<template:addResources type="javascript" resources="jquery.js"/>
<template:addResources type="javascript" resources="jquery.fancybox.js"/>
<template:addResources type="css" resources="jquery.fancybox.css"/>

<workflow:activeWorkflow node="${currentNode}" var="activeWorkflows"/>
<jsp:useBean id="activeWorkflowsMap" class="java.util.HashMap"/>
<c:forEach items="${activeWorkflows}" var="activeWorkflow">
    <c:set target="${activeWorkflowsMap}" property="${activeWorkflow.workflowDefinition.key}"
           value="${activeWorkflow}"/>
</c:forEach>
<workflow:workflowsForNode checkPermission="false" node="${currentNode}" var="workflowDefinitions"
                           workflowAction="${currentResource.moduleParams.workflowType}"/>
<c:forEach items="${workflowDefinitions}" var="workflowDefinition">
<workflow:tasksForNode node="${currentNode}" var="tasksForNode"/>
<jsp:useBean id="tasks" class="java.util.HashMap"/>
<c:forEach items="${tasksForNode}" var="task" varStatus="status">
    <c:if test="${task.workflowDefinition == workflowDefinition}">
        <c:set target="${tasks}" property="${task.name}" value="${task}"/>
    </c:if>
</c:forEach>

<p>
    <a id="workflowImageLink${fn:replace(currentNode.identifier,'-','')}${fn:replace(workflowDefinition.key,'-','')}"
       href="#workflowImage${fn:replace(currentNode.identifier,'-','')}${fn:replace(workflowDefinition.key,'-','')}">!!!View workflow status</a>
</p>
<jsp:useBean id="historyTasks" class="java.util.HashMap"/>
<c:if test="${not empty activeWorkflowsMap[workflowDefinition.key]}">
    <c:if test="${currentResource.moduleParams.showHistory == 'true'}">
        <workflow:workflowHistory var="history" workflowId="${activeWorkflowsMap[workflowDefinition.key].id}"
                                  workflowProvider="${activeWorkflowsMap[workflowDefinition.key].provider}"/>
        !!!History:
        <ul>
            <c:forEach items="${history}" var="historyTask">
                <c:set target="${historyTasks}" property="${historyTask.name}" value="${historyTask}"/>
                <c:if test="${not empty historyTask.endTime}">
                    <li>
                            ${historyTask.displayName}
                        <ul>
                            <li>!!!User: ${historyTask.user}</li>
                            <li>!!!Duration: ${historyTask.duration/1000}s</li>
                            <li>!!!Started: <fmt:formatDate value="${historyTask.startTime}"
                                                          pattern="yyyy-MM-dd HH:mm:ss"/></li>
                            <li>!!!Ended: <fmt:formatDate value="${historyTask.endTime}"
                                                        pattern="yyyy-MM-dd HH:mm:ss"/></li>
                            <li>!!!Outcome: ${historyTask.displayOutcome}</li>
                        </ul>
                    </li>
                </c:if>
            </c:forEach>
        </ul>
    </c:if>
    !!!Open tasks:
    <ul>
        <c:forEach items="${activeWorkflowsMap[workflowDefinition.key].availableActions}" var="action">
            <c:if test="${(empty currentResource.moduleParams.task) or (!empty currentResource.moduleParams.task and currentResource.moduleParams.task == action.name)}">
                <li>
                        ${action.displayName} <c:if test="${not empty tasks[action.name]}"> - <a class="workflowLink"
                                                                                                 id="linktask${currentNode.identifier}-${tasks[action.name].id}"
                                                                                                 href="#task${currentNode.identifier}-${tasks[action.name].id}">!!!Execute</a></c:if>
                    <ul>
                        <li>!!!Started: <fmt:formatDate value="${action.createTime}" pattern="yyyy-MM-dd HH:mm:ss"/></li>
                        <li>!!!Due for: <fmt:formatDate value="${action.dueDate}" pattern="yyyy-MM-dd HH:mm:ss"/></li>
                    </ul>
                </li>
            </c:if>
        </c:forEach>
    </ul>
</c:if>

<div style="display:none">
    <div id="workflowImage${fn:replace(currentNode.identifier,'-','')}${fn:replace(workflowDefinition.key,'-','')}">
        <div id="workflowImageDiv${fn:replace(currentNode.identifier,'-','')}${fn:replace(workflowDefinition.key,'-','')}" style="position:relative;">
            <div style="height:50px;"></div>
            <img src="<c:url value='/cms/wfImage?workflowKey=${workflowDefinition.provider}:${workflowDefinition.key}'/>"/>

            <c:forEach items="${activeWorkflowsMap[workflowDefinition.key].availableActions}" var="task"
                       varStatus="status">
                <div id="running${task.id}" class="runningtask-div"
                     style="position:absolute;display:none;border-radius: 15px;background-color:red;opacity:0.2;"
                     onmouseover="$('#runningInfo${task.id}').show()"
                     onmouseout="$('#runningInfo${task.id}').hide()"
                     onclick="$('#linktask${currentNode.identifier}-${task.id}').click()">
                </div>
                <div id="runningInfo${task.id}"
                     style="display:none;position:absolute;border:2px solid black;background-color:white">
                    <ul>
                        <li>!!!Started: <fmt:formatDate value="${task.createTime}" pattern="yyyy-MM-dd HH:mm:ss"/></li>
                        <li>!!!Due for: <fmt:formatDate value="${task.dueDate}" pattern="yyyy-MM-dd HH:mm:ss"/></li>
                    </ul>
                </div>
            </c:forEach>
            <c:forEach items="${historyTasks}" var="task" varStatus="status">
                <c:if test="${not empty task.value.endTime}">
                    <div id="history${task.value.actionId}" class="historytask-div"
                         style="position:absolute;display:none;border-radius: 15px;background-color:green;opacity:0.5;"
                         onmouseover="$('#historyInfo${task.value.actionId}').show()"
                         onmouseout="$('#historyInfo${task.value.actionId}').hide()">
                    </div>
                    <div id="historyInfo${task.value.actionId}"
                         style="display:none;position:absolute;border:2px solid black;background-color:white">
                        <ul>
                            <li>!!!User: ${task.value.user}</li>
                            <li>!!!Duration: ${task.value.duration/1000}s</li>
                            <li>!!!Started: <fmt:formatDate value="${task.value.startTime}"
                                                          pattern="yyyy-MM-dd HH:mm:ss"/></li>
                            <li>!!!Ended: <fmt:formatDate value="${task.value.endTime}"
                                                        pattern="yyyy-MM-dd HH:mm:ss"/></li>
                            <li>!!!Outcome: ${task.value.displayOutcome}</li>
                        </ul>
                    </div>
                </c:if>
            </c:forEach>

        </div>
    </div>
</div>

<script>
    function startWorkflow(process) {
        $.post("<c:url value='${url.base}${functions:escapeJavaScript(currentNode.path)}.startWorkflow.do'/>", {"process":process},
                function (result) {
                    location.reload();
                },
                'json'
        );
    }


    function executeTask(action, outcome) {
        $.post("<c:url value='${url.base}${functions:escapeJavaScript(currentNode.path)}.executeTask.do'/>", {"action":action, "outcome":outcome},
                function (result) {
                    location.reload();
                },
                'json'
        );
    }

    var animated = false;

    function loop(value) {
        $("#" + value).fadeIn("slow", function () {
            $("#" + value).fadeOut("slow", function () {
                if (animated) {
                    loop(value);
                }
            });
        });
    }

    function animateWorkflowTask${fn:replace(currentNode.identifier,'-','')}${fn:replace(workflowDefinition.key,'-','')}() {
        animated = true;
        $.post('<c:url value="${url.base}${functions:escapeJavaScript(currentNode.path)}.getWorkflowTasks.do"/>', {'workflowKey':'${workflowDefinition.provider}:${workflowDefinition.key}'}, function (result) {
            <c:forEach items="${activeWorkflowsMap[workflowDefinition.key].availableActions}" var="task" varStatus="status">
            coords = result['${task.name}'];
            $("#running${task.id}").css('left', coords[0] + "px");
            $("#running${task.id}").css('top', (parseInt(coords[1]) + 50) + "px");
            $("#running${task.id}").css('width', coords[2] + "px");
            $("#running${task.id}").css('height', coords[3] + "px");
            $("#runningInfo${task.id}").css('left', coords[0] + "px");
            $("#runningInfo${task.id}").css('top', (parseInt(coords[1]) + 50 + parseInt(coords[3])) + "px");
            $('#running${task.id}').fadeIn();
            </c:forEach>

            <c:forEach items="${tasks}" var="task" varStatus="status">
            loop('running${task.value.id}');
            </c:forEach>

            <c:forEach items="${historyTasks}" var="task" varStatus="status">
            coords = result['${task.key}'];
            $("#history${task.value.actionId}").css('left', coords[0] + "px");
            $("#history${task.value.actionId}").css('top', (parseInt(coords[1]) + 50) + "px");
            $("#history${task.value.actionId}").css('width', coords[2] + "px");
            $("#history${task.value.actionId}").css('height', coords[3] + "px");
            $("#historyInfo${task.value.actionId}").css('left', coords[0] + "px");
            $("#historyInfo${task.value.actionId}").css('top', (parseInt(coords[1]) + 50 + parseInt(coords[3])) + "px");
            $('#history${task.value.actionId}').fadeIn();
            </c:forEach>
        }, 'json');
    }

    function stopAnimateWorkflowTask() {
        animated = false;
        $('.runningtask-div').hide();
        $('.historytask-div').hide();
    }

    $(document).ready(function () {

        $("#workflowImageLink${fn:replace(currentNode.identifier,'-','')}${fn:replace(workflowDefinition.key,'-','')}").fancybox({
            'onComplete':animateWorkflowTask${fn:replace(currentNode.identifier,'-','')}${fn:replace(workflowDefinition.key,'-','')},
            'onCleanup':stopAnimateWorkflowTask
        });

        $(".workflowLink").fancybox();
    });


</script>
<c:if test="${empty activeWorkflowsMap[workflowDefinition.key]}">
    <a href="#" onclick="startWorkflow('${workflowDefinition.provider}:${workflowDefinition.key}')">Start workflow</a>
</c:if>

<c:forEach items="${tasks}" var="entry">
    <c:set value="${entry.value}" var="task"/>
    <div style="display:none">
        <div id="task${currentNode.identifier}-${task.id}" class="taskformdiv popupSize">
            <c:choose>
                <c:when test="${not empty task.formResourceName}">
                    <c:set var="workflowTaskFormTask" value="${task}" scope="request"/>
                    <c:url value="${url.current}.ajax" var="myUrl"/>
                    <template:include view="contribute.workflow">
                        <template:param name="resourceNodeType" value="${task.formResourceName}"/>
                        <template:param name="workflowTaskForm" value="${task.provider}:${task.id}"/>
                        <template:param name="workflowTaskFormTaskName" value="${task.name}"/>
                    </template:include>
                </c:when>
                <c:otherwise>
                    <div class="FormContribute">
                        <form>
                            <fieldset>
                                <legend>${task.displayName}</legend>
                                <div class="divButton">
                                    <c:forEach items="${task.outcomes}" var="outcome" varStatus="status">
                                        <button type="button" class="form-button workflowaction"
                                                onclick="executeTask('${task.provider}:${task.id}', '${outcome}')"><span
                                                class="icon-contribute icon-accept"></span>&nbsp;<span>${task.displayOutcomes[status.index]}</span>
                                        </button>
                                    </c:forEach>
                                </div>
                            </fieldset>
                        </form>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

</c:forEach>
</c:forEach>
<c:if test="${empty workflowDefinitions}">
    !!!No workflow set for: ${currentResource.moduleParams.workflowType}
</c:if>
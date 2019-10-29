<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix ="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ include file="../include/header.jsp" %>

	<div class="row">
		<div class="col-lg-12">
			<h1 class="page-header">Board Register</h1>
		</div>
	</div>
	
	<div class="row">
		<div class="col-lg-12">
			<div class="panel panel-default">
				<div class="panel-heading">Board Register</div>
				<div class="panel-body">
					<form action="/board/modify" id="myForm" method="post">
						<div class="form-group">
							<label>Bno</label>
							<input class="form-control" name="bno" value="${board.bno}" readonly="readonly" />
						</div>
						<div class="form-group">
							<label>Title</label>
							<input class="form-control" name="title" value="${board.title}"/>
						</div>
						<div class="form-group">
							<label>Text Area</label>
							<textarea class="form-control" rows="3" name="content" >${board.content }</textarea>
						</div>
						<div class="form-group">
							<label>Writer</label>
							<input class="form-control" name="writer" value="${board.writer}"/>
						</div>
						<div class="form-group">
							<label>RegDate</label>
							<input class="form-control" name="regdate" value="<fmt:formatDate pattern ='yyyy/MM/dd' value='${board.regdate}'/>" 
								readonly="readonly"/>
						</div>
						<div class="form-group">
							<label>Update Date</label>
							<input class="form-control" name="updatedate" value="<fmt:formatDate pattern ='yyyy/MM/dd' value='${board.updatedate}'/>" 
								readonly="readonly"/>
						</div>
						<div style="text-align: right;">
							<sec:authentication property="principal" var="pinfo"/>
								<sec:authorize access="isAuthenticated()">
									<c:if test="${pinfo.username eq board.writer}">
										<button type="submit" data-oper="modify" class="btn btn-default">수정하기</button>
										<button type="submit" data-oper="remove" class="btn btn-danger">삭제하기</button>
									</c:if>
								</sec:authorize>
							<button type="submit" data-oper="list" class="btn btn-info">목록으로</button>
						</div>
						
						<input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
						<input type="hidden" name="pageNum" value="${cri.pageNum}" />
						<input type="hidden" name="amount" value="${cri.amount}" />
					</form>
				</div>
			</div>
		</div>
	</div>
	
<div class="bigPictureWrapper">
	<div class="bigPicture">
	</div>
</div>
<style>
.uploadResult {
  width:100%;
  background-color: gray;
}
.uploadResult ul{
  display:flex;
  flex-flow: row;
  justify-content: center;
  align-items: center;
}
.uploadResult ul li {
  list-style: none;
  padding: 10px;
  align-content: center;
  text-align: center;
}
.uploadResult ul li img{
  width: 100px;
}
.uploadResult ul li span {
  color:white;
}
.bigPictureWrapper {
  position: absolute;
  display: none;
  justify-content: center;
  align-items: center;
  top:0%;
  width:100%;
  height:100%;
  background-color: gray; 
  z-index: 100;
  background:rgba(255,255,255,0.5);
}
.bigPicture {
  position: relative;
  display:flex;
  justify-content: center;
  align-items: center;
}

.bigPicture img {
  width:600px;
}

</style>
<div class="row">
  <div class="col-lg-12">
    <div class="panel panel-default">

      <div class="panel-heading">Files</div>
      <!-- /.panel-heading -->
      <div class="panel-body">
        <div class="form-group uploadDiv">
        	<input type="file" name="uploadFile" multiple />
        </div>
        <div class='uploadResult'> 
          <ul>
          </ul>
        </div>
      </div>
      <!--  end panel-body -->
    </div>
    <!--  end panel-body -->
  </div>
  <!-- end panel -->
</div>
<!-- /.row -->
<script>
	$(document).ready(function(){
		var formObj = $("#myForm");

		$("button").on("click",function(e){
			e.preventDefault();
			
			var operation = $(this).data("oper");
			
			if(operation === 'remove'){
				formObj.attr("action", "/board/remove");
			}else if(operation === 'list'){
				// move to list
				formObj.attr('action','/board/list').attr('method','get');
				
				var pageNumTag = $("input[name='pageNum']").clone();
				var amountTag = $("input[name='amount']").clone();
				
				formObj.empty();
				formObj.append(pageNumTag);
				formObj.append(amountTag);
			}else if(operation == 'modify'){
				console.log("submit clicked");
				
				var str = "";
				
				$(".uploadResult ul li").each(function(i, obj){
					var jobj = $(obj);
					console.dir(jobj);
					
					str += "<input type='hidden' name='attachList["+i+"].fileName' value='"+jobj.data("filename")+"'>";
					str += "<input type='hidden' name='attachList["+i+"].uuid' value='"+jobj.data("uuid")+"'>";
					str += "<input type='hidden' name='attachList["+i+"].uploadPath' value='"+jobj.data("path")+"'>";
					str += "<input type='hidden' name='attachList["+i+"].fileType' value='"+jobj.data("type")+"'>";
				});
				formObj.append(str);
			}
			formObj.submit();
		});
		
		(function(){
			var bno = '<c:out value="${board.bno}"/>';
			$.getJSON("/board/getAttachList", {bno: bno}, function(arr){
				console.log(arr);
				
				var str = "";
				
				$(arr).each(function(i, attach){
					
					//image type
					if(attach.fileType){
			            var fileCallPath =  encodeURIComponent( attach.uploadPath+ "/s_"+attach.uuid +"_"+attach.fileName);
			            
			            str += "<li data-path='"+attach.uploadPath+"' data-uuid='"+attach.uuid+"' "
			            str +=" data-filename='"+attach.fileName+"' data-type='"+attach.fileType+"' ><div>";
			            str += "<span> "+ attach.fileName+"</span>";
			            str += "<button type='button' data-file=\'"+fileCallPath+"\' data-type='image' "
			            str += "class='btn btn-warning btn-circle'><i class='fa fa-times'></i></button><br>";
			            str += "<img src='/display?fileName="+fileCallPath+"'>";
			            str += "</div>";
			            str +"</li>";
			          }else{
			              
			            str += "<li data-path='"+attach.uploadPath+"' data-uuid='"+attach.uuid+"' "
			            str += "data-filename='"+attach.fileName+"' data-type='"+attach.fileType+"' ><div>";
			            str += "<span> "+ attach.fileName+"</span><br/>";
			            str += "<button type='button' data-file=\'"+fileCallPath+"\' data-type='file' "
			            str += " class='btn btn-warning btn-circle'><i class='fa fa-times'></i></button><br>";
			            str += "<img src='/resources/img/attach.png'></a>";
			            str += "</div>";
			            str +"</li>";
			          }
				});
				$('.uploadResult ul').html(str);
			});
		})();
		
		$(".uploadResult").on("click", "button", function(e){
			console.log("delete file");
			
			if(confirm("Remove this file? ")){
				var targetLi = $(this).closest("li");
				targetLi.remove();
			}
		});
		
		var regex = new RegExp("(.*?)\.(exe|sh|zip|alz)$");
		var maxSize = 5242880; //5MB
		
		function checkExtension(fileName, fileSize){
			if(fileSize >= maxSize){
				alert("파일 사이즈 초과");
				return false;
			}
			
			if(regex.test(fileName)){
				alert("해당 종류의 파일은 업로드할 수 없습니다.");
				return false;
			}
			return true;
		}
		
		var csrfHeaderName = "${_csrf.headerName}";
		var csrfTokenValue = "${_csrf.token}";
		
		$("input[type='file']").change(function(e){
			var formData = new FormData();
			
			var inputFile = $("input[name='uploadFile']");
			
			var files = inputFile[0].files;
			
			for(var i =0; i<files.length; i++){
				if(!checkExtension(files[i].name, files[i].size)){
					return false;
				}
				formData.append("uploadFile", files[i]);
			}
			
			$.ajax({
				url:'/uploadAjaxAction',
				processData:false,
				contentType:false,
				data:formData,
				beforeSend:function(xhr){
					xhr.setRequestHeader(csrfHeaderName, csrfTokenValue);
				},
				type:"POST",
				dataType:"json",
				success:function(result){
					console.log(result);
					showUploadResult(result);
				}
			});
		});
		
		function showUploadResult(uploadResultArr){
			
			if(!uploadResultArr || uploadResultArr.length == 0) {return;}
			
			var uploadUL = $(".uploadResult ul");
			
			var str="";
			
			$(uploadResultArr).each(function(i, obj){
				if(obj.image){
					var fileCallPath =  encodeURIComponent( obj.uploadPath+ "/s_"+obj.uuid +"_"+obj.fileName);
					str += "<li data-path='"+obj.uploadPath+"'";
					str +=" data-uuid='"+obj.uuid+"' data-filename='"+obj.fileName+"' data-type='"+obj.image+"'"
					str +" ><div>";
					str += "<span> "+ obj.fileName+"</span>";
					str += "<button type='button' data-file=\'"+fileCallPath+"\' "
					str += "data-type='image' class='btn btn-warning btn-circle'><i class='fa fa-times'></i></button><br>";
					str += "<img src='/display?fileName="+fileCallPath+"'>";
					str += "</div>";
					str +"</li>";
				}else{
					var fileCallPath =  encodeURIComponent( obj.uploadPath+"/"+ obj.uuid +"_"+obj.fileName);			      
				    var fileLink = fileCallPath.replace(new RegExp(/\\/g),"/");
				      
					str += "<li "
					str += "data-path='"+obj.uploadPath+"' data-uuid='"+obj.uuid+"' data-filename='"+obj.fileName+"' data-type='"+obj.image+"' ><div>";
					str += "<span> "+ obj.fileName+"</span>";
					str += "<button type='button' data-file=\'"+fileCallPath+"\' data-type='file' " 
					str += "class='btn btn-warning btn-circle'><i class='fa fa-times'></i></button><br>";
					str += "<img src='/resources/img/attach.png'></a>";
					str += "</div>";
					str +"</li>";
				}
			});
			uploadUL.append(str);
		}
	});
</script>
<%@ include file="../include/footer.jsp" %>